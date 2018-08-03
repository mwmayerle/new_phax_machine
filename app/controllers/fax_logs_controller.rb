class FaxLogsController < ApplicationController
	include SessionsHelper
	
	before_action :verify_is_manager_or_admin
	before_action :set_phaxio_creds

	def index
		if is_admin?
			fax_log = FaxLog.get_first_twenty_five_faxes
			
			# Create a hash to reference for Organizations. Prevents program from querying the database constantly
			@organizations = {}
			Organization.all.each do |organization_object| 
				@organizations[organization_object.fax_tag] = {}
				@organizations[organization_object.fax_tag]['label'] = organization_object.label
				@organizations[organization_object.fax_tag]['org_created_at'] = organization_object.created_at
			end

			# Same logic as the @organizations hash created above
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
				users[index][:caller_id_number] = user_object.caller_id_number
				users[index][:user_created_at] = user_object.created_at
				users[index][:fax_tag] = user_object.fax_tag
			end

			@fax_numbers = fax_numbers.keys.map { |fax_number| FaxNumber.format_pretty_fax_number(fax_number) }
			@fax_numbers.unshift("All")

			@organizations[:All] = {}
			@organizations[:All]['label'] = 'All'

			@sorted_faxes = FaxLog.format_first_twenty_five_faxes_admin(fax_log, @organizations, fax_numbers, users)

		elsif is_manager?
			organization = Organization.find(current_user.organization_id)

			users = {}
			organization.users.each_with_index do |user_object, index|
				users[index] = {}
				users[index][:email] = user_object.email
				users[index][:caller_id_number] = user_object.caller_id_number
				users[index][:user_created_at] = user_object.created_at
				users[index][:fax_tag] = user_object.fax_tag
			end

			fax_numbers = FaxNumber.where({ organization_id: organization.id }).all.map {|fax_num| fax_num.fax_number}

			fax_log = FaxLog.get_first_twenty_five_faxes(organization.fax_tag, organization.id, fax_numbers)

			@sorted_faxes = FaxLog.format_first_twenty_five_faxes_manager(fax_log, fax_numbers, organization, users)
		end
	end

	# create in this controller is for user-designated filtering
	def create
		start_time = log_filter_params[:start_time].to_datetime.rfc3339 if params[:fax_log][:start_time] != ""
		end_time = log_filter_params[:end_time].to_datetime.rfc3339 if params[:fax_log][:end_time] != ""
		fax_number = Phonelib.parse(log_filter_params[:fax_number].prepend('1')).e164 if params[:fax_log][:fax_number] != "All"
		org_fax_tag = log_filter_params[:organization] if params[:fax_log][:organization] != "All" && is_admin?
	end

	private
		def set_phaxio_creds
			Fax.set_phaxio_creds
		end

		def log_filter_params
			params.require(:fax_log).permit(:start_time, :end_time, :fax_number, :organization)
		end
end