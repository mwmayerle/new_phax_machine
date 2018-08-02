class FaxLog < ApplicationRecord
	include SessionsHelper

	class << self
		def get_first_twenty_five_faxes(fax_tag = nil, organization_id = nil, fax_numbers = nil) # Phaxio API returns 25 by default
			if fax_tag.nil?
				fax_data = Phaxio::Fax.list({:created_before => Time.now, :created_after => 1.years.ago, :per_page => 24 })
			else
				per_page_number =  24 / fax_numbers.length

				# First search for faxes using each fax_number associated with the Organization
				fax_data = []
				fax_numbers.each do |fax_number|
					current_data = Phaxio::Fax.list({
						:phone_number => fax_number,
						:created_before => Time.now,
						:created_after => 1.years.ago,
						:per_page => per_page_number
					})
					fax_data.push(current_data.raw_data)
				end

				# Then search for faxes via organization's fax tag and add these faxes.
				tag_data = Phaxio::Fax.list({
					:tag => { 
						:sender_organization_fax_tag => fax_tag
					},
					:created_before => Time.now,
					:created_after => 1.years.ago,
					:per_page => per_page_number
				})
				fax_data.push(tag_data.raw_data)
			end
			fax_data
		end

		def format_first_twenty_five_faxes_admin(fax_log, organizations, fax_numbers, users, fax_data = {})
			fax_log.each do |fax_object|
				fax_data[fax_object.id] = {}
				fax_data[fax_object.id][:status] = fax_object.status.titleize
				fax_data[fax_object.id][:direction] = fax_object.direction.titleize

				if fax_object.direction == "received"
					# Checks to make sure that the fax object existed after the organization was created
					if fax_numbers[fax_object.to_number] && fax_object_is_younger?(fax_object.created_at, fax_numbers[fax_object.to_number]['org_created_at']) 
						fax_data[fax_object.id][:organization] = fax_numbers[fax_object.to_number]['label']
					end

					fax_data[fax_object.id][:to_number] = FaxNumber.format_pretty_fax_number(fax_object.to_number)
					fax_data[fax_object.id][:from_number] = FaxNumber.format_pretty_fax_number(fax_object.from_number)

				else # fax_object.direction == "sent"
					# Checks if fax_object has a fax tag that matches an existing organization's fax tag
					if organizations[fax_object.tags['sender_organization_fax_tag']]
						# If the organization object was created before the fax existed, then use its label
						if fax_object_is_younger?(fax_object.created_at, organizations[fax_object.tags['sender_organization_fax_tag']]['org_created_at'])
							fax_data[fax_object.id][:organization] = organizations[fax_object.tags['sender_organization_fax_tag']]['label']
						end
					end

					if fax_object.caller_id
						fax_data[fax_object.id][:from_number] = FaxNumber.format_pretty_fax_number(fax_object.caller_id)
					end

					if fax_object.recipients.length == 1
						fax_data[fax_object.id][:to_number] = FaxNumber.format_pretty_fax_number(fax_object.recipients.raw_data[0]['phone_number'])
					elsif fax_object.recipients.length > 1
						fax_data[fax_object.id][:to_number] = "Multiple"
					end

					users.each do |user_obj_key, user_obj_data|
						if fax_object.tags['sender_email_fax_tag'] == user_obj_data[:fax_tag]
							fax_data[fax_object.id][:sent_by] = user_obj_data[:email]
						end
					end

				end
				fax_data[fax_object.id][:organization] = "N/A" if fax_data[fax_object.id][:organization].nil?
				fax_data[fax_object.id][:created_at] = format_fax_log_time(fax_object.created_at)
			end
			fax_data
		end

		def format_first_twenty_five_faxes_manager(fax_log, fax_numbers, organization, users, fax_data = {}, all_faxes = [])
			# The fax_log arg is an array of arrays, so this code chunk (to the sort_by) pulls out each fax object and 
			# dumps it into a single array, sorts it by 'created_at', and then iterates through that final array
			fax_log.each do |faxes_per_phone_number|
				faxes_per_phone_number.each do |fax_object|
					all_faxes.push(fax_object)
				end
			end
			all_faxes = all_faxes.sort_by { |fax| fax[:created_at] }.reverse

			all_faxes.each do |fax_object|
				fax_data[fax_object['id']] = {}
				fax_data[fax_object['id']][:status] = fax_object['status'].titleize
				fax_data[fax_object['id']][:direction] = fax_object['direction'].titleize

				if fax_object['direction'] == "received"
					# Checks to make sure that the fax object existed after the organization was created
					fax_data[fax_object['id']][:to_number] = FaxNumber.format_pretty_fax_number(fax_object['to_number'])
					fax_data[fax_object['id']][:from_number] = FaxNumber.format_pretty_fax_number(fax_object['from_number'])
				else

					users.each do |user_obj_key, user_obj_data|
						if fax_object['tags']['sender_email_fax_tag'] == user_obj_data[:fax_tag] #&& fax_object_is_younger?(fax_object['created_at'].to_time, user_obj_data[:user_created_at])
							fax_data[fax_object['id']][:sent_by] = user_obj_data[:email]
						end
					end

					if fax_object['recipients'].length == 1
						fax_data[fax_object['id']][:to_number] = FaxNumber.format_pretty_fax_number(fax_object['recipients'][0]['phone_number'])
					elsif fax_object['recipients'].length > 1
						fax_data[fax_object['id']][:to_number] = "Multiple"
					end

					fax_data[fax_object['id']][:from_number] = FaxNumber.format_pretty_fax_number(fax_object['caller_id']) if fax_object['caller_id']
				end
				fax_data[fax_object['id']][:created_at] = format_fax_log_time(fax_object['created_at'])
			end
			fax_data
		end

		def fax_object_is_younger?(fax_object_timestamp, comparison_obj_timestamp)
			Time.at(fax_object_timestamp) > Time.at(comparison_obj_timestamp)
		end

		def format_fax_log_time(time)
			time.to_time.strftime("%r - %m/%d/%Y")
		end

	end

end