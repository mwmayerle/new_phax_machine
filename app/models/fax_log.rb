require 'date'

# TODO iterate thru deleted orgs (add them to paranoia) and then put a symbol next to them to indicate they have been rip'ed
class FaxLog < ApplicationRecord
	class << self
		def build_options(current_user, filtered_params, options = {})
			options[:start_time] = add_start_time(filtered_params[:start_time])# if filtered_params[:start_time]
			options[:end_time] = add_end_time(filtered_params[:end_time]) #if filtered_params[:end_time]
			options[:tag] = filtered_params[:tag] if !filtered_params[:tag].nil?
			
			if filtered_params[:status]
				options[:status] = filtered_params[:status] if filtered_params[:status] != "all"	
			end

			if filtered_params[:fax_number]
				options[:fax_number] = Phonelib.parse(filtered_params[:fax_number]).e164 if filtered_params[:fax_number] != "all"
			end

			if filtered_params[:organization]
				options[:tag] = { :sender_organization_fax_tag => filtered_params[:organization] } if filtered_params[:organization] != "all"
			end

			if current_user.user_permission.permission == UserPermission::MANAGER
				if filtered_params[:user]
					options[:tag] = { :sender_email_fax_tag => filtered_params[:user] } if filtered_params[:user] != "all"
				end
			end
			options
		end

		def get_faxes(current_user, options, fax_numbers = nil, fax_data = [])
			if options[:tag].nil? # Admin gets everything
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
					fax_object_recipient_data_is_in_fax_numbers?(fax_object, fax_numbers) || sent_fax_caller_id_is_in_fax_numbers?(fax_object, fax_numbers)
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
					# fax_data.push(current_data.raw_data)
					filtered_current_data = current_data.raw_data.select do |fax_object|
						fax_numbers.include?(fax_object['from_number']) || fax_numbers.include?(fax_object['to_number'])
					end
					fax_data.push(filtered_current_data)
				end
			end
			fax_data
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
					if current_user.user_permission.permission == UserPermission::ADMIN
						if fax_numbers[fax_object['to_number']] && fax_object_is_younger?(fax_object['created_at'], fax_numbers[fax_object['to_number']]['org_created_at'])
							fax_data[fax_object['id']]['organization'] = fax_numbers[fax_object['to_number']]['label']
						else 
							fax_data[fax_object['id']]['organization'] = "N/A"
						end
					end

					fax_data[fax_object['id']]['to_number'] = FaxNumber.format_pretty_fax_number(fax_object['to_number'])
					fax_data[fax_object['id']]['from_number'] = FaxNumber.format_pretty_fax_number(fax_object['from_number'])

				else # fax_object.direction == "sent"

					if current_user.user_permission.permission == UserPermission::ADMIN
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
		def fax_object_recipient_data_is_in_fax_numbers?(fax_object, fax_numbers)
			fax_object['recipients'].select { |recipient| fax_numbers.keys.include?(recipient['phone_number']) }.any?
		end

		#Iterate through fax objects and 
		def sent_fax_caller_id_is_in_fax_numbers?(fax_object, fax_numbers)
			fax_object['direction'] == 'sent' && fax_numbers.keys.include?(fax_object['caller_id'])
		end

		# Converts "08-01-2018" to "01-08-2018" for 'to_datetime' conversion
		def format_date(input_time)
			original_year = input_time[6..-1]
			original_month = input_time[0..2]
			original_day = input_time[3..5]
			original_day.concat(original_month).concat(original_year)
		end

		def add_start_time(input_time)
			input_time.to_s == "" ? 7.days.ago.to_datetime.rfc3339 : format_date(input_time).to_datetime.rfc3339
		end

		def add_end_time(input_time)
			input_time.to_s == "" ? DateTime.now.rfc3339 : format_date(input_time).to_datetime.rfc3339
		end

		def fax_object_is_younger?(fax_object_timestamp, comparison_obj_timestamp)
			Time.at(fax_object_timestamp.to_time) > Time.at(comparison_obj_timestamp.to_time)
		end

		def format_initial_fax_data_time(time)
			time.to_time.strftime("%I:%M:%S%P - %m/%d/%y")
		end

		def sort_faxes(initial_fax_data, all_faxes = [])
			# The initial_fax_data arg is an array of arrays at this line
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
	end
end