require 'date'

# TODO iterate thru deleted orgs (add them to paranoia) and then put a symbol next to them to indicate they have been rip'ed
# 'NOTICE is_manager?' and 'is_admin?' are unique to this model and behave differently than the similarly named helper methods

class FaxLog < ApplicationRecord
	class << self
		# Build the options object that will be used later
		def build_options(current_user, filtered_params, organization, options = {})
			options[:start_time] = add_start_time(filtered_params[:start_time])
			options[:end_time] = add_end_time(filtered_params[:end_time])
			options[:tag] = filtered_params[:tag] if !filtered_params[:tag].nil?
			
			set_status_in_options(filtered_params, options) if filtered_params[:status]
			set_fax_number_in_options(filtered_params, options) if filtered_params[:fax_number]
			set_organization_in_options(filtered_params, organization, options) if filtered_params[:organization]
			set_tag_in_options_manager(filtered_params, organization, options) if is_manager?(current_user)
			set_tag_in_options_user(filtered_params, organization, options, current_user) if is_user?(current_user)
			options
		end

		def get_faxes(current_user, options, users, fax_numbers = nil, fax_data = [])
			# options[:tag] will contain a specific desired organization or user. Managers will always have an organization
			if options[:tag].nil? # Admin gets everything unless they specify and organization
				initial_data = Phaxio::Fax.list({
					created_before: options[:end_time],
					created_after: options[:start_time],
					per_page: options[:per_page],
					status: options[:status]
				}) # created_before defaults to now, created_after defaults to a week ago
				fax_data.push(initial_data.raw_data)

			else
				options[:per_page] = 20 / fax_numbers.keys.length if options[:per_page].nil?
				# First search for faxes via organization fax tag or user's fax tag and insert these faxes. If I try to include the desired
				# fax number(s) in this API call as well, it will only return received faxes b/c those will have the tags on them.
				tag_data = Phaxio::Fax.list(
					created_before: options[:end_time],
					created_after: options[:start_time],
					tag: options[:tag],
					per_page: options[:per_page],
					status: options[:status]
				)

				new_data = tag_data.raw_data.select do |fax_object|
					fax_obj_recipient_data_in_fax_numbers?(fax_object, fax_numbers) || sent_caller_id_in_fax_numbers?(fax_object, fax_numbers)
				end
				fax_data.push(new_data)

				# Then search for faxes using each fax_number associated with the Organization
				fax_numbers.keys.each do |fax_number|
					options[:phone_number] = fax_number
					current_data = Phaxio::Fax.list(
						created_before: options[:end_time],
						created_after: options[:start_time],
						phone_number: fax_number,
						per_page: options[:per_page],
						status: options[:status]
					)

					# Filter by fax number if a specific fax number exists and it isn't "all" or "all-linked"
					if options[:fax_number].nil?
						filtered_data = current_data.raw_data
					else
						filtered_data = filter_faxes_by_fax_number(options, current_data.raw_data, fax_numbers)
					end

					# Filter by user if a user-specific tag exists
					filtered_data = filter_faxes_by_user(options, filtered_data) if options[:tag].has_key?(:sender_email_fax_tag)
					fax_data.push(filtered_data)
				end
			end
			fax_data
		end

		def filter_faxes_by_fax_number(options, current_data, fax_numbers)
			current_data.select { |fax_object| fax_numbers.include?(fax_object['from_number']) || fax_numbers.include?(fax_object['to_number']) }
		end

		def filter_faxes_by_user(options, filtered_data)
			filtered_data.select do |fax_object|
				received_fax_is_from_user?(fax_object, options) || sent_fax_is_from_user?(fax_object, options)
			end
		end

		def received_fax_is_from_user?(fax_object, options)
			fax_object['direction'] == 'received' && (fax_object['from_number'] == User.find_by(fax_tag: options[:tag][:sender_email_fax_tag]).caller_id_number)
		end

		def sent_fax_is_from_user?(fax_object, options)
			fax_object['direction'] == 'sent' && (fax_object['caller_id'] == User.find_by(fax_tag: options[:tag][:sender_email_fax_tag]).caller_id_number)
		end

		def format_faxes(current_user, initial_fax_data, organizations, fax_numbers, users = nil, fax_data = {})
			all_faxes = sort_faxes(initial_fax_data)

			all_faxes.each do |fax_object|
				fax_data[fax_object['id']] = {}
				fax_data[fax_object['id']]['status'] = fax_object['status'].titleize
				fax_data[fax_object['id']]['direction'] = fax_object['direction'].titleize

				if fax_object['direction'] == 'received'

					users.each do |user_obj_key, user_obj_data|
						if fax_object['from_number'] == user_obj_data['caller_id_number'] && fax_object_is_younger?(fax_object['created_at'], user_obj_data['user_created_at'])

							fax_data[fax_object['id']]['sent_by'] = user_obj_data['email']
						end
					end

					# Checks to make sure that the fax object existed after the organization was created
					if is_admin?(current_user)
						if fax_numbers[fax_object['to_number']] && fax_object_is_younger?(fax_object['created_at'], fax_numbers[fax_object['to_number']]['org_created_at'])

							fax_data[fax_object['id']]['organization'] = fax_numbers[fax_object['to_number']]['label']
						else
							fax_data[fax_object['id']]['organization'] = "N/A"
						end
					end

					fax_data[fax_object['id']]['to_number'] = FaxNumber.format_pretty_fax_number(fax_object['to_number'])
					fax_data[fax_object['id']]['from_number'] = FaxNumber.format_pretty_fax_number(fax_object['from_number'])

				else # fax_object.direction == "sent"

					if is_admin?(current_user)
						# # Checks if fax_object has a fax tag that matches an existing organization's fax tag
						if organizations[fax_object['tags']['sender_organization_fax_tag']]
						# If the organization object was created before the fax existed, then use its label
							if fax_object_is_younger?(fax_object['created_at'], organizations[fax_object['tags']['sender_organization_fax_tag']]['org_created_at'])

								fax_data[fax_object['id']]['organization'] = organizations[fax_object['tags']['sender_organization_fax_tag']]['label']
							end
						end
					end
					
					if fax_object['caller_id']
						fax_data[fax_object['id']]['from_number'] = FaxNumber.format_pretty_fax_number(fax_object['caller_id'])
					end

					if fax_object['recipients'].length == 1
						fax_data[fax_object['id']]['to_number'] = FaxNumber.format_pretty_fax_number(fax_object['recipients'][0]['phone_number'])
					elsif fax_object['recipients'].length > 1
						fax_data[fax_object['id']]['to_number'] = "Multiple"
					end

					users.each do |user_obj_key, user_obj_data|
						if fax_object['tags']['sender_email_fax_tag'] == user_obj_data['fax_tag']
							fax_data[fax_object['id']]['sent_by'] = user_obj_data['email']
						end
					end

				end #the if/else for fax direction

				fax_data[fax_object['id']]['created_at'] = format_initial_fax_data_time(fax_object['created_at'])
			end 
			fax_data
		end

		# Iterate thru recipient phone numbers of a fax object and return true or false if select returns more than '[]' (1+ match)
		def fax_obj_recipient_data_in_fax_numbers?(fax_object, fax_numbers)
			fax_object['recipients'].select { |recipient| fax_numbers.keys.include?(recipient['phone_number']) }.any?
		end

		#Iterate through fax objects and 
		def sent_caller_id_in_fax_numbers?(fax_object, fax_numbers)
			fax_object['direction'] == 'sent' && fax_numbers.keys.include?(fax_object['caller_id'])
		end

		def add_start_time(input_time)
			input_time.to_s == "" ? 7.days.ago.to_datetime.utc.rfc3339 : format_date(input_time).to_datetime.utc.rfc3339
		end

		def add_end_time(input_time)
			input_time.to_s == "" ? DateTime.now.utc.rfc3339 : format_date(input_time).to_datetime.utc.rfc3339
		end
		
		def set_status_in_options(filtered_params, options)
			options[:status] = filtered_params[:status] if filtered_params[:status] != "all"
		end

		def set_fax_number_in_options(filtered_params, options)
			options[:fax_number] = Phonelib.parse(filtered_params[:fax_number]).e164
		end

		def set_organization_in_options(filtered_params, organization, options)
			options[:tag] = { :sender_organization_fax_tag => filtered_params[:organization] } if filtered_params[:organization] != "all"
		end

		def set_tag_in_options_manager(filtered_params, organization, options)
			# finds "all-user" and "all". Ruby's .match() returns nil if it finds nothing and nil is falsy, so !!nil is false
			if !!/all/.match(filtered_params[:user]) || filtered_params[:user].nil?
				options[:tag] = { :sender_organization_fax_tag => organization.fax_tag }
			else
				options[:tag] = { :sender_email_fax_tag => User.find_by(email: filtered_params[:user]).fax_tag }
			end
		end

		def set_tag_in_options_user(filtered_params, organization, options, current_user)
			options[:tag] = { :sender_email_fax_tag => current_user.fax_tag }
		end

		# Converts "08-01-2018" to "01-08-2018" for 'to_datetime' conversion
		def format_date(input_time)
			original_year = input_time[6..-1]
			original_month = input_time[0..2]
			original_day = input_time[3..5]
			original_day.concat(original_month).concat(original_year)
		end

		def fax_object_is_younger?(fax_object_timestamp, comparison_obj_timestamp)
			Time.at(fax_object_timestamp.to_time) > Time.at(comparison_obj_timestamp.to_time)
		end

		def format_initial_fax_data_time(time)
			time.to_time.strftime("%I:%M:%S%P - %m/%d/%y")
		end

		def sort_faxes(initial_fax_data, all_faxes = [])
			# The initial_fax_data arg is an array of arrays at this line, so we sort it prior to making a hash
			initial_fax_data.each do |faxes_per_phone_number|
				faxes_per_phone_number.each do |fax_object|
					all_faxes.push(fax_object)
				end
			end
			all_faxes.sort_by { |fax| fax['created_at'] }.reverse!
		end

		def create_orgs_hash(organizations_hash, organization_object)
			organizations_hash[organization_object.fax_tag] = {'label' => organization_object.label }
			organizations_hash[organization_object.fax_tag]['org_created_at'] = organization_object.created_at
			organizations_hash[organization_object.fax_tag]['org_id'] = organization_object.id
		end

		def create_fax_nums_hash(fax_numbers_hash, fax_number_object)
			fax_numbers_hash[fax_number_object.fax_number] = {'label' => fax_number_object.organization.label}
			fax_numbers_hash[fax_number_object.fax_number]['org_created_at'] = fax_number_object.organization.created_at
			fax_numbers_hash[fax_number_object.fax_number]['org_id'] = fax_number_object.organization.id
		end

		def create_users_hash(users_hash, user_obj, index)
			users_hash[index] = { 'email' => user_obj.email }
			users_hash[index]['caller_id_number'] = user_obj.caller_id_number
			users_hash[index]['user_created_at'] = user_obj.created_at
			users_hash[index]['fax_tag'] = user_obj.fax_tag
			users_hash[index]['org_id'] = user_obj.organization.id if user_obj.user_permission.permission != UserPermission::ADMIN
		end

		def add_all_attribute_to_hashes(hashes)
			hashes.each { |hash_obj| hash_obj['all'] = { 'label' => 'all' } }
		end

		def is_user?(current_user)
			current_user.user_permission.permission == UserPermission::USER
		end

		def is_manager?(current_user)
			current_user.user_permission.permission == UserPermission::MANAGER
		end

		def is_admin?(current_user)
			current_user.user_permission.permission == UserPermission::ADMIN
		end
	end
end