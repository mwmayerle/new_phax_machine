require 'date'
# 'NOTICE is_manager?' and 'is_admin?' are unique to this model and behave differently than the similarly named helper methods
class FaxLog < ApplicationRecord
	class << self
		# Build the options object that will be used later
		def build_options(current_user, filtered_params, organizations, users, fax_numbers, options = {})
			options[:tag] = filtered_params[:tag] if !filtered_params[:tag].nil?
			options[:fax_number] = set_fax_number_in_options(filtered_params, options)

			set_tag_in_options_manager(filtered_params, organizations, options, users) if is_manager?(current_user)
			set_tag_in_options_user(filtered_params, organizations, options, current_user) if is_user?(current_user)

			set_status_in_options(filtered_params, options) if filtered_params[:status]
			set_organization_in_options(filtered_params, organizations, options) if filtered_params[:organization]

			options[:start_time] = add_start_time(current_user, filtered_params, organizations, users)
			options[:end_time] = add_end_time(filtered_params[:end_time])
			p options
			options
		end

		def get_faxes(current_user, options, filtered_params, users = nil, fax_numbers = nil, organizations = nil, fax_data = [])
			# options[:tag] will contain a specific desired organization or user. Managers will always have an organization
			if options[:tag].nil? # Admin gets everything unless they specify and organization
				initial_data = Phaxio::Fax.list({
					created_before: options[:end_time],
					created_after: options[:start_time],
					per_page: options[:per_page],
					status: options[:status]
				})
				fax_data.push(initial_data.raw_data)

			else
				begin
					# There will be an unknown amount of fax objects returned per number, so this will get
					#  around 20 results on this initial page load. Afterwards it'll be limited to 1000
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

				if options[:tag].has_key?(:sender_organization_fax_tag) && !!/all/.match(filtered_params[:fax_number])
					new_data = tag_data.raw_data
				elsif options[:tag].has_key?(:sender_email_fax_tag) && !!/all/.match(filtered_params[:fax_number])
					new_data = tag_data.raw_data
				else
					new_data = filter_for_desired_fax_number(tag_data.raw_data, fax_numbers)
				end
				fax_data.push(new_data) if !new_data.nil?

				# Then search for faxes using each fax_number associated with the Organization
				fax_numbers.keys.each do |fax_number|
					options[:fax_number] = fax_number
					current_data = Phaxio::Fax.list(
						# created_after: options[:start_time],
						created_after: fax_numbers[fax_number][:org_switched_at],
						created_before: options[:end_time],
						phone_number: options[:fax_number],
						per_page: options[:per_page],
						status: options[:status]
					)

					if current_data.total > 0 # <-- no result catch
						# Filter by fax number if a specific fax number exists and it isn't "all" or "all-linked"
						if options[:fax_number].nil?
							filtered_data = current_data.raw_data
						else
							filtered_data = filter_faxes_by_fax_number(options, current_data.raw_data, fax_numbers)
							if options[:tag][:sender_organization_fax_tag] && filtered_data != nil
								filtered_data = filter_faxes_by_org_date(options, filtered_data, organizations[options[:tag][:sender_organization_fax_tag]])

								# This prevents sent faxes from other organizations from appearing when they shouldn't
								filtered_data = filtered_data.select { |fax_object| fax_numbers.keys.include?(fax_object[:to_number]) }
							end
						end

						# Filter by user if a user-specific tag exists
						# NOTE 'users' when filtering by a single user will be a single object from the set_users method, despite
						#   having a plural name. This is for code re-use.
						if options[:tag][:sender_email_fax_tag]
							user_key = users.select { |user_key, user_data| user_data[:fax_tag] == options[:tag][:sender_email_fax_tag] }.keys.pop
							user_fax_numbers = UserFaxNumber.where(user_id: users[user_key][:user_id])
								.map { |user_fax_number| user_fax_number.fax_number }
								.map { |fax_number| fax_number.fax_number }

							filtered_sent_data = filter_faxes_by_user_sent(options, filtered_data, users[user_key])
							filtered_received_data = filter_faxes_by_user_received(options, filtered_data, users[user_key], user_fax_numbers)
							filtered_data = filtered_received_data + filtered_sent_data
						end
					else
						filtered_data = current_data.raw_data
					end #current_data.total
					fax_data.push(filtered_data) if filtered_data != nil
				end
			end
			fax_data
		end

		def filter_for_desired_fax_number(tag_data, fax_numbers)
			recipient_numbers = tag_data.select { |fax_object| fax_obj_recipient_data_in_fax_numbers?(fax_object, fax_numbers) }
			sent_numbers = tag_data.select { |fax_object| sent_caller_id_in_fax_numbers?(fax_object, fax_numbers) }
			results = recipient_numbers + sent_numbers
			results = results.uniq
		end

		def filter_faxes_by_fax_number(options, current_data, fax_numbers)
			sent_faxes = current_data.select { |fax_object| fax_object[:direction] == 'sent' }
			received_faxes = current_data.select { |fax_object| fax_object[:direction] == 'received' }

			if sent_faxes.empty?
				caller_id_data = []
				recipients_data = []
			else
				caller_id_data = sent_faxes.select { |fax_object| fax_numbers.keys.include?(fax_object[:caller_id]) }
				recipients_data = sent_faxes.select do |fax_object|
					fax_object[:recipients].select do |recipient| 
						fax_numbers.keys.include?(recipient[:phone_number])
					end
				end
			end

			if received_faxes.empty?
				from_number_data = []
				to_number_data = []
			else
				from_number_data = received_faxes.select { |fax_object| fax_numbers.keys.include?(fax_object[:from_number]) }
				to_number_data = received_faxes.select { |fax_object| fax_numbers.keys.include?(fax_object[:to_number]) }
			end

			new_data = from_number_data + to_number_data + caller_id_data + recipients_data
			new_data = new_data.uniq
			new_data
		end

		def filter_faxes_by_org_date(options, filtered_data, organizations)
			filtered_data.select { |fax_object| fax_object_is_younger?(fax_object[:created_at], organizations[:org_created_at]) }
		end

		def filter_faxes_by_user_sent(options, filtered_data, user)
			filtered_data.select { |fax_object| sent_fax_is_from_user?(fax_object, options, user) }
		end

		def filter_faxes_by_user_received(options, filtered_data, user, user_fax_numbers)
		  filtered_data.select { |fax_object| received_fax_was_sent_by_user?(fax_object, options, user, user_fax_numbers) }
		end

		def sent_fax_is_from_user?(fax_object, options, user)
			# user argument is a hash that looks like {0 => {'caller_id_number' => '+12345678910', 'attribute' => 'etc'} }
			return false if fax_object[:direction] == 'received'
			fax_object[:caller_id] == user[:caller_id_number] && fax_object[:tags][:sender_email_fax_tag] == user[:fax_tag] && fax_object_is_younger?(fax_object[:created_at], user[:user_created_at])
		end

		def received_fax_was_sent_by_user?(fax_object, options, user, user_fax_numbers)
			return false if fax_object[:direction] == 'sent' 
			user_fax_numbers.include?(fax_object[:to_number]) && fax_object_is_younger?(fax_object[:created_at], user[:user_created_at])
		end

		def format_faxes(current_user, all_faxes, organizations, fax_numbers, users = nil, fax_data = {})
			all_faxes.each do |fax_object|
				fax_data[fax_object[:id]] = {
					:status => fax_object[:status].titleize,
					:direction => fax_object[:direction].titleize
				}

				if fax_object[:direction] == 'received'
					# if fax_numbers[fax_object[:to_number]] && fax_object_is_younger?(fax_object[:created_at], fax_numbers[fax_object[:to_number]][:org_created_at])
					if fax_numbers[fax_object[:to_number]] && fax_object_is_younger?(fax_object[:created_at], fax_numbers[fax_object[:to_number]][:org_switched_at])
						# NOTE 'label' on the line below is the organization the fax number is associated with. See 'created_fax_nums_hash' method
						fax_data[fax_object[:id]][:organization] = fax_numbers[fax_object[:to_number]][:label]
					# elsif fax_numbers[fax_object[:from_number]] && fax_object_is_younger?(fax_object[:created_at], fax_numbers[fax_object[:from_number]][:org_created_at])
					elsif fax_numbers[fax_object[:from_number]] && fax_object_is_younger?(fax_object[:created_at], fax_numbers[fax_object[:from_number]][:org_switched_at])
						fax_data[fax_object[:id]][:organization] = fax_numbers[fax_object[:from_number]][:label]
					else
						fax_data[fax_object[:id]][:organization] = ""
					end

					fax_data[fax_object[:id]][:to_number] = FaxNumber.format_pretty_fax_number(fax_object[:to_number])
					fax_data[fax_object[:id]][:from_number] = FaxNumber.format_pretty_fax_number(fax_object[:from_number])

				else # fax_object[:direction] == "sent"

					if is_admin?(current_user)
						# Checks if fax_object has a fax tag that matches an existing organization's fax tag
						if organizations[fax_object[:tags][:sender_organization_fax_tag]]
						# If the organization object was created before the fax existed, then use its label
							if fax_object_is_younger?(fax_object[:created_at], organizations[fax_object[:tags][:sender_organization_fax_tag]][:org_created_at])
								fax_data[fax_object[:id]][:organization] = organizations[fax_object[:tags][:sender_organization_fax_tag]][:label]
							end
						end
					end
					
					fax_data[fax_object[:id]][:from_number] = FaxNumber.format_pretty_fax_number(fax_object[:caller_id]) if fax_object[:caller_id]

					if fax_object[:recipients].length == 1
						fax_data[fax_object[:id]][:to_number] = FaxNumber.format_pretty_fax_number(fax_object[:recipients][0][:phone_number])
					elsif fax_object[:recipients].length > 1
						fax_data[fax_object[:id]][:to_number] = "Multiple"
					end

					users.each do |user_obj_key, user_obj_data|
						if fax_object[:tags][:sender_email_fax_tag] == user_obj_data[:fax_tag]
							fax_data[fax_object[:id]][:sent_by] = user_obj_data[:email]
						end
					end
				end #the if/else for fax direction

				fax_data[fax_object[:id]][:created_at] = format_initial_fax_data_time(fax_object[:created_at])
			end 
			fax_data
		end

		# Iterate thru recipient phone numbers of a fax object and return true or false if select returns more than '[]' (1+ match)
		def fax_obj_recipient_data_in_fax_numbers?(fax_object, fax_numbers)
			fax_object[:recipients].select { |recipient| fax_numbers.keys.include?(recipient[:phone_number]) }.any?
		end

		def sent_caller_id_in_fax_numbers?(fax_object, fax_numbers)
			fax_object[:direction] == 'sent' && fax_numbers.keys.include?(fax_object[:caller_id])
		end

################# build_options methods ################# 

		# This method modifies the user-submitted start time to whenever the desired parameter was created to avoid asking
		#   the API for data from a huge time range that predates what the user wants
		def add_start_time(current_user, filtered_params, organizations, users)
			filtered_params[:start_time] = filtered_params[:start_time].to_s == "" ? (DateTime.now - 7) : filtered_params[:start_time].to_time
			if is_manager?(current_user)
				if !!/all/.match(filtered_params[:user]) && timestamp_is_older?(filtered_params[:start_time], current_user.organization.created_at)
					filtered_params[:start_time] = current_user.organization.created_at 
				else
					# User objects in the hash look like:
					#   {1=>{:email=>"org_one_user@aol.com", :caller_id_number=>"+15555834355", :user_created_at=>Wed, 19 Sep 2018 18:22:04 UTC +00:00, :fax_tag=>"sdfg2776-d2be-0000-a6fb-58a12345ea2c", :org_id=>1}}
					#   This returns the key in the hash (e.g. [1])
					user_key = users.select { |user_key, user_data| user_data[:email] == filtered_params[:user] }.keys.pop
					if (user_key && timestamp_is_older?(filtered_params[:start_time], users[user_key][:user_created_at])) || (user_key && timestamp_is_older?(current_user.organization.created_at, users[user_key][:user_created_at]))
						filtered_params[:start_time] = current_user.organization.created_at
					end
				end

			end

			if is_user?(current_user)
				filtered_params[:start_time] = current_user.created_at if timestamp_is_older?(filtered_params[:start_time], current_user.created_at)
			end

			filtered_params[:start_time].rfc3339
		end

		def timestamp_is_older?(param_start_time, comparison_obj_time)
			return if param_start_time.nil?
			Time.at(param_start_time.to_time) > Time.at(comparison_obj_time.to_time)
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

		def set_tag_in_options_manager(filtered_params, organizations, options, users)
			# finds "all-user" and "all". Ruby's .match() returns nil if it finds nothing and nil is falsy, so !!nil is false
			if !!/all/.match(filtered_params[:user]) || filtered_params[:user].nil?
				# organizations is a hash where the key is the fax_tag
				options[:tag] = { :sender_organization_fax_tag => organizations.keys[0] }
			else
				users.each do |index_key, user_obj_hash|
					org_key = organizations.keys[0]
					if user_obj_hash[:org_id] == organizations[org_key][:org_id] && user_obj_hash[:email] == filtered_params[:user]
						options[:tag] = { :sender_email_fax_tag => user_obj_hash[:fax_tag] }
					end
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
			all_faxes.sort_by { |fax| fax[:created_at] }.reverse!
		end

		def fax_object_is_younger?(fax_object_timestamp, comparison_obj_timestamp)
			Time.at(fax_object_timestamp.to_time) > Time.at(comparison_obj_timestamp.to_time)
		end

		def format_initial_fax_data_time(time)
			time.to_time.strftime("%I:%M:%S%P - %m/%d/%y")
		end

################# setting data prior to get_faxes and format_faxes ################# 

		def create_orgs_hash(organizations_hash, organization_object)
			organizations_hash[organization_object.fax_tag] = {
				:label => organization_object.label,
				:org_created_at => organization_object.created_at,
				:org_id => organization_object.id,
				:soft_deleted => !!organization_object.deleted_at
			}
		end

		def create_fax_nums_hash(fax_numbers_hash, fax_number_object)
			fax_numbers_hash[fax_number_object.fax_number] = {
				:label => fax_number_object.organization.label,
				:org_created_at => fax_number_object.organization.created_at,
				:org_id => fax_number_object.organization.id,
				:org_switched_at => fax_number_object.org_switched_at
			}
		end

		def create_users_hash(users_hash, user_obj, index)
			users_hash[index] = { 
				:email => user_obj.email,
				:caller_id_number => user_obj.caller_id_number,
				:user_created_at => user_obj.created_at,
				:fax_tag => user_obj.fax_tag,
				:org_id => user_obj.organization_id,
				:user_id => user_obj.id,
				:soft_deleted => user_obj.deleted_at,
			}
		end

		def add_all_attribute_to_hashes(hashes) # hashes is an array of hashes[@fax_numbers, @users]
			hashes.each { |hash_obj| hash_obj['all'] = { :label => :all } }
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