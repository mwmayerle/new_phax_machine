require 'date'

# TODO iterate thru deleted orgs (add them to paranoia) and then put a symbol next to them to indicate they have been rip'ed
# 'NOTICE is_manager?' and 'is_admin?' are unique to this model and behave differently than the similarly named helper methods

class FaxLog < ApplicationRecord
	class << self
		# Build the options object that will be used later
		def build_options(current_user, filtered_params, organization, users, options = {})
			options[:start_time] = add_start_time(filtered_params[:start_time])
			options[:end_time] = add_end_time(filtered_params[:end_time])
			options[:tag] = filtered_params[:tag] if !filtered_params[:tag].nil?
			options[:fax_number] = set_fax_number_in_options(filtered_params, options)

			set_status_in_options(filtered_params, options) if filtered_params[:status]
			set_organization_in_options(filtered_params, organization, options) if filtered_params[:organization]

			set_tag_in_options_manager(filtered_params, organization, options, users) if is_manager?(current_user)
			set_tag_in_options_user(filtered_params, organization, options, current_user) if is_user?(current_user)
			options
		end

		def get_faxes(current_user, options, users = nil, fax_numbers = nil, organizations = nil, fax_data = [])
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
				begin
					options[:per_page] = 20 / fax_numbers.keys.length if options[:per_page].nil?
				rescue
					options[:per_page] = 20 # <-- if a user has no fax numbers this prevents a division by zero error
				end
				
				# First search for faxes via organization fax tag or user's fax tag and insert these faxes. If I try to include the desired
				# fax number(s) in this API call as well, it will only return received faxes b/c those will have the tags on them.
				tag_data = Phaxio::Fax.list(
					created_before: options[:end_time],
					created_after: options[:start_time],
					tag: options[:tag],
					per_page: options[:per_page],
					status: options[:status]
				)

				if !!organizations[options[:tag][:sender_organization_fax_tag]]
					new_data = tag_data.raw_data
				else
					new_data = filter_for_desired_fax_number_data(tag_data.raw_data, fax_numbers)
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
					if options[:phone_number].nil?
						filtered_data = current_data.raw_data
					else
						filtered_data = filter_faxes_by_fax_number(options, current_data.raw_data, fax_numbers)
					end

					# Filter by user if a user-specific tag exists
					# NOTE 'users' when filtering by a single user will be a single object from the set_users method, despite
					#   having a plural name. This is for code re-use. 
					filtered_data = filter_faxes_by_user(options, filtered_data, users) if options[:tag].has_key?(:sender_email_fax_tag)
					fax_data.push(filtered_data)
				end
			end
			fax_data
		end

		def filter_for_desired_fax_number_data(tag_data, fax_numbers)
			tag_data.select do |fax_object|
				fax_obj_recipient_data_in_fax_numbers?(fax_object, fax_numbers) || sent_caller_id_in_fax_numbers?(fax_object, fax_numbers)
			end
		end

		def filter_faxes_by_fax_number(options, current_data, fax_numbers)
			current_data.select { |fax_object| fax_numbers.include?(fax_object['from_number']) || fax_numbers.include?(fax_object['to_number']) }
		end

		def filter_faxes_by_user(options, filtered_data, user)
			filtered_data.select do |fax_object|
				# received_fax_is_from_user?(fax_object, options, user) && fax_object['direction'] == 'received' || sent_fax_is_from_user?(fax_object, options, user) && fax_object['direction'] == 'sent' 
				sent_fax_is_from_user?(fax_object, options, user) && fax_object['direction'] == 'sent' || fax_object['direction'] == 'received'
			end
		end

		# def received_fax_is_from_user?(fax_object, options, user)
		# 	# user argument is a hash that looks like {0 => {'caller_id_number' => '+12345678910', 'attribute' => 'etc'} }
		# 	fax_object['from_number'] == user[0]['caller_id_number']
		# end

		def sent_fax_is_from_user?(fax_object, options, user)
			# user argument is a hash that looks like {0 => {'caller_id_number' => '+12345678910', 'attribute' => 'etc'} }
			fax_object['caller_id'] == user[0]['caller_id_number'] && options[:tag][:sender_email_fax_tag] == user[0]['fax_tag']
		end

		def format_faxes(current_user, initial_fax_data, organizations, fax_numbers, users = nil, fax_data = {})
			all_faxes = sort_faxes(initial_fax_data)

			all_faxes.each do |fax_object|
				fax_data[fax_object['id']] = {}
				fax_data[fax_object['id']]['status'] = fax_object['status'].titleize
				fax_data[fax_object['id']]['direction'] = fax_object['direction'].titleize

				if fax_object['direction'] == 'received'

				###############################################################################
				# This commented out code block fails if multiple users have the same caller_id_number attribute. Because a hash is being
				# used, the 'sent_by' value associated with the key (fax_object's ID) will be overwritten with the last true match and it
				# will display the wrong (or correct) sender based on who is the last user

				# users.each do |user_obj_key, user_obj_data|
				# 	if fax_object['from_number'] == user_obj_data['caller_id_number'] && fax_object_is_younger?(fax_object['created_at'], user_obj_data['user_created_at'])
				# 		fax_data[fax_object['id']]['sent_by'] = user_obj_data['email']
				# 	end
				# end
				###############################################################################
					
					# if is_admin?(current_user) # Checks to make sure that the fax object existed after the organization was created
						if fax_numbers[fax_object['to_number']] && fax_object_is_younger?(fax_object['created_at'], fax_numbers[fax_object['to_number']]['org_created_at'])
					# NOTE 'label' on the line below is the organization the fax number is associated with. See 'created_fax_nums_hash' method
							fax_data[fax_object['id']]['organization'] = fax_numbers[fax_object['to_number']]['label']
						elsif fax_numbers[fax_object['from_number']] && fax_object_is_younger?(fax_object['created_at'], fax_numbers[fax_object['from_number']]['org_created_at'])
							fax_data[fax_object['id']]['organization'] = fax_numbers[fax_object['from_number']]['label']
						else
							fax_data[fax_object['id']]['organization'] = "N/A"
						end
					# end

					#### ADD soft-deleted orgs in place of N/A

					fax_data[fax_object['id']]['to_number'] = FaxNumber.format_pretty_fax_number(fax_object['to_number'])
					fax_data[fax_object['id']]['from_number'] = FaxNumber.format_pretty_fax_number(fax_object['from_number'])

				else # fax_object.direction == "sent"

					if is_admin?(current_user)
						# Checks if fax_object has a fax tag that matches an existing organization's fax tag
						if organizations[fax_object['tags']['sender_organization_fax_tag']]
						# If the organization object was created before the fax existed, then use its label
							if fax_object_is_younger?(fax_object['created_at'], organizations[fax_object['tags']['sender_organization_fax_tag']]['org_created_at'])
								fax_data[fax_object['id']]['organization'] = organizations[fax_object['tags']['sender_organization_fax_tag']]['label']
							end
						end
					end
					
					fax_data[fax_object['id']]['from_number'] = FaxNumber.format_pretty_fax_number(fax_object['caller_id']) if fax_object['caller_id']

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

					#ADD soft-deleted users portion

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

################# build_options methods ################# 

		def add_start_time(input_time)
			# https://stackoverflow.com/questions/5905861/how-do-i-add-two-weeks-to-time-now
			# DateTime.now - 7 is subtracting a week
			input_time.to_s == "" ? (DateTime.now - 7).rfc3339 : input_time.to_time.to_datetime.rfc3339
		end

		def add_end_time(input_time)
			input_time.to_s == "" ? Time.now.to_datetime.rfc3339 : input_time.to_time.to_datetime.rfc3339
		end
		
		def set_status_in_options(filtered_params, options)
			options[:status] = filtered_params[:status] if filtered_params[:status] != "all"
		end

		def set_fax_number_in_options(filtered_params, options)
			!!/all/.match(filtered_params[:fax_number]) ? filtered_params[:fax_number] : Phonelib.parse(filtered_params[:fax_number]).e164
		end

		def set_organization_in_options(filtered_params, organization, options)
			options[:tag] = { :sender_organization_fax_tag => filtered_params[:organization] } if filtered_params[:organization] != "all"
		end

		def set_tag_in_options_manager(filtered_params, organization, options, users)
			# finds "all-user" and "all". Ruby's .match() returns nil if it finds nothing and nil is falsy, so !!nil is false
			if !!/all/.match(filtered_params[:user]) || filtered_params[:user].nil?
				options[:tag] = { :sender_organization_fax_tag => organization.fax_tag }
			else
				users.each do |index_key, user_obj_hash|
					options[:tag] = { :sender_email_fax_tag => user_obj_hash['fax_tag'] } if user_obj_hash['org_id'] == organization.id
				end
			end
		end

		def set_tag_in_options_user(filtered_params, organization, options, current_user)
			options[:tag] = { :sender_email_fax_tag => current_user.fax_tag }
		end

############################### format_faxes methods ###################################

		def sort_faxes(initial_fax_data, all_faxes = [])
			# The initial_fax_data arg is an array of arrays at this line, so we sort it prior to making a hash
			initial_fax_data.each do |faxes_per_phone_number|
				faxes_per_phone_number.each do |fax_object|
					all_faxes.push(fax_object)
				end
			end
			all_faxes.sort_by { |fax| fax['created_at'] }.reverse!
		end

		def fax_object_is_younger?(fax_object_timestamp, comparison_obj_timestamp)
			Time.at(fax_object_timestamp.to_time) > Time.at(comparison_obj_timestamp.to_time)
		end

		def format_initial_fax_data_time(time)
			time.to_time.strftime("%I:%M:%S%P - %m/%d/%y")
		end

################# setting data prior to get_faxes and format_faxes ################# 

		def create_orgs_hash(organizations_hash, organization_object)
			organizations_hash[organization_object.fax_tag] = {'label' => organization_object.label }
			organizations_hash[organization_object.fax_tag]['org_created_at'] = organization_object.created_at
			organizations_hash[organization_object.fax_tag]['org_id'] = organization_object.id
			organizations_hash[organization_object.fax_tag]['soft_deleted'] = !!organization_object.deleted_at
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
			users_hash[index]['org_id'] = user_obj.organization_id
		end

		def add_all_attribute_to_hashes(hashes) # hashes is an array [@fax_numbers, @users]
			hashes.each { |hash_obj| hash_obj['all'] = { 'label' => 'all' } }
		end

######################## Permission Methods #################################

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