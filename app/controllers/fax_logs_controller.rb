class FaxLogsController < ApplicationController
	include SessionsHelper
	
	before_action :set_phaxio_creds

	def index
			@fax_numbers = {}
			@users = {}

		if is_admin?
			# Create a hash to reference for Organizations. Prevents program from querying the database constantly
			@organizations = {}
			Organization.all.each { |organization_obj| FaxLog.create_orgs_hash(@organizations, organization_obj) }

			# Same logic as the @organizations hash created above. Gets all Fax Numbers w/an associated Organization
			FaxNumber.where.not(organization_id: nil).all.each { |fax_number_obj| FaxLog.create_fax_nums_hash(@fax_numbers, fax_number_obj) }

			User.all.each_with_index { |user_obj, index| FaxLog.create_users_hash(@users, user_obj, index) if user_obj.id != 1 }

			fax_log = FaxLog.get_first_twenty_five_faxes
		else
			# Find a single Organization b/c User and Manager can only be in 1
			org = Organization.find(current_user.organization_id)

			# Isolate Fax Numbers w/the found organization's ID
			FaxNumber.where({ organization_id: org.id }).each { |fax_num_obj| FaxLog.create_fax_nums_hash(@fax_numbers, fax_num_obj) }

			# Get users in an Organization is viewer is Manager, otherwise just use the current user.
			criteria_array = is_manager? ? org.users : [current_user] # current_user is in array for iterating/code reuse
			criteria_array.each_with_index { |user_obj, index| FaxLog.create_users_hash(@users, user_obj, index) }

			fax_tag_criteria = is_manager? ? {sender_organization_fax_tag: org.fax_tag} : {sender_email_fax_tag: current_user.fax_tag}
			fax_log = FaxLog.get_first_twenty_five_faxes(fax_tag_criteria, org.id, @fax_numbers)
		end
		
		if is_admin?
			FaxLog.add_all_attribute_to_hashes([@users, @fax_numbers, @organizations])
			@sorted_faxes = FaxLog.format_faxes(current_user, fax_log, @organizations, @fax_numbers, @users)
		else
			FaxLog.add_all_attribute_to_hashes( [@users, @fax_numbers] )
			@sorted_faxes = FaxLog.format_faxes(current_user, fax_log, @fax_numbers, org, @users)
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