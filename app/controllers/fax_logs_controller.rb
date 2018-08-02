class FaxLogsController < ApplicationController
	include SessionsHelper
	
	before_action :verify_is_manager_or_admin
	before_action :set_phaxio_creds

	def index
		if is_admin?
			fax_log = FaxLog.get_first_twenty_five_faxes
			
			# Create a hash to reference for Organizations. Prevents program from querying the database constantly
			organizations = {}
			Organization.all.each do |organization_object| 
				organizations[organization_object.fax_tag] = {}
				organizations[organization_object.fax_tag]['label'] = organization_object.label
				organizations[organization_object.fax_tag]['org_created_at'] = organization_object.created_at
			end

			# Same logic as the organizations hash created above
			fax_numbers = {}
			FaxNumber.all.each do |fax_num| 
				if fax_num.organization 
					fax_numbers[fax_num.fax_number] = {}
					fax_numbers[fax_num.fax_number]['label'] = fax_num.organization.label
					fax_numbers[fax_num.fax_number]['org_created_at'] = fax_num.organization.created_at
				end
			end

			users = {}
			User.all.each_with_index do |user_object, index|
				users[index] = {}
				users[index][:email] = user_object.email
				users[index][:user_created_at] = user_object.created_at
				users[index][:fax_tag] = user_object.fax_tag
			end

			@sorted_faxes = FaxLog.format_first_twenty_five_faxes_admin(fax_log, organizations, fax_numbers, users)

		elsif is_manager?
			organization = Organization.find(current_user.organization_id)

			users = {}
			organization.users.each_with_index do |user_object, index|
				users[index] = {}
				users[index][:email] = user_object.email
				users[index][:user_created_at] = user_object.created_at
				users[index][:fax_tag] = user_object.fax_tag
			end

			fax_numbers = FaxNumber.where({ organization_id: organization.id }).all.map {|fax_num| fax_num.fax_number}

			fax_log = FaxLog.get_first_twenty_five_faxes(organization.fax_tag, organization.id, fax_numbers)

			@sorted_faxes = FaxLog.format_first_twenty_five_faxes_manager(fax_log, fax_numbers, organization, users)
		end
	end

	private
		def set_phaxio_creds
			Fax.set_phaxio_creds
		end
end