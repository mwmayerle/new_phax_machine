class FaxLogsController < ApplicationController
	include SessionsHelper
	
	before_action :set_phaxio_creds

	def index
		if is_admin?
			# Create a hash to reference for Organizations. Prevents program from querying the database constantly
			@organizations = {}
			Organization.all.each do |organization_object| 
				@organizations[organization_object.fax_tag] = {}
				@organizations[organization_object.fax_tag]['label'] = organization_object.label
				@organizations[organization_object.fax_tag]['org_created_at'] = organization_object.created_at
				@organizations[organization_object.fax_tag]['org_id'] = organization_object.id
			end

			# Same logic as the @organizations hash created above
			@fax_numbers = {}
			FaxNumber.all.each do |fax_num| 
				if fax_num.organization 
					@fax_numbers[fax_num.fax_number] = {}
					@fax_numbers[fax_num.fax_number]['label'] = fax_num.organization.label
					@fax_numbers[fax_num.fax_number]['org_created_at'] = fax_num.organization.created_at
					@fax_numbers[fax_num.fax_number]['org_id'] = fax_num.organization.id
				end
			end

			@users = {}
			User.all.each_with_index do |user_object, index|
				if user_object.user_permission.permission != UserPermission::ADMIN #admin does not send/receive faxes
					@users[index] = {}
					@users[index]['email'] = user_object.email
					@users[index]['caller_id_number'] = user_object.caller_id_number
					@users[index]['user_created_at'] = user_object.created_at
					@users[index]['fax_tag'] = user_object.fax_tag
					@users[index]['org_id'] = user_object.organization.id if user_object.user_permission.permission != UserPermission::ADMIN
				end
			end

			@fax_numbers['All'] = {}
			@fax_numbers['All']['label'] = "All"

			@organizations['All'] = {}
			@organizations['All']['label'] = 'All'

			@users['All'] = {}
			@users['All']['label'] = "All"

			fax_log = FaxLog.get_first_twenty_five_faxes
			@sorted_faxes = FaxLog.format_faxes(current_user, fax_log, @organizations, @fax_numbers, @users)

		elsif is_manager?
			organization = Organization.find(current_user.organization_id)

			@users = {}
			organization.users.each_with_index do |user_object, index|
				@users[index] = {}
				@users[index]['email'] = user_object.email
				@users[index]['caller_id_number'] = user_object.caller_id_number
				@users[index]['user_created_at'] = user_object.created_at
				@users[index]['fax_tag'] = user_object.fax_tag
			end

			@fax_numbers = {}
			FaxNumber.where({ organization_id: organization.id }).each do |fax_num| 
				if fax_num.organization 
					@fax_numbers[fax_num.fax_number] = {}
					@fax_numbers[fax_num.fax_number]['label'] = fax_num.organization.label
					@fax_numbers[fax_num.fax_number]['org_created_at'] = fax_num.organization.created_at
					@fax_numbers[fax_num.fax_number]['org_id'] = fax_num.organization.id
				end
			end

			fax_log = FaxLog.get_first_twenty_five_faxes({ sender_organization_fax_tag: organization.fax_tag }, organization.id, @fax_numbers)

			@fax_numbers['All'] = {}
			@fax_numbers['All']['label'] = "All"

			@users['All'] = {}
			@users['All']['label'] = "All"

			@sorted_faxes = FaxLog.format_faxes(current_user, fax_log, @fax_numbers, organization, @users)

		else #UserPermission::USER
			organization = Organization.find(current_user.organization_id)

			@fax_numbers = {}
			current_user.fax_numbers.each do |fax_num| 
				@fax_numbers[fax_num.fax_number] = {}
				@fax_numbers[fax_num.fax_number]['label'] = fax_num.organization.label
				@fax_numbers[fax_num.fax_number]['org_created_at'] = fax_num.organization.created_at
				@fax_numbers[fax_num.fax_number]['org_id'] = fax_num.organization.id
			end

			@users = {} # This looks odd b/c it allows code reuse in other methods
			@users['user'] = {}
			@users['user']['email'] = current_user.email
			@users['user']['caller_id_number'] = current_user.caller_id_number
			@users['user']['user_created_at'] = current_user.created_at
			@users['user']['fax_tag'] = current_user.fax_tag

			fax_log = FaxLog.get_first_twenty_five_faxes({ sender_email_fax_tag: current_user.fax_tag }, organization.id, @fax_numbers)

			@fax_numbers['All'] = {}
			@fax_numbers['All']['label'] = "All"

			@users['All'] = {}
			@users['All']['label'] = "All"

			@sorted_faxes = FaxLog.format_faxes(current_user, fax_log, @fax_numbers, organization, @users)
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
			params.require(:fax_log).permit(:start_time, :end_time, :fax_number, :organization, :user)
		end
end