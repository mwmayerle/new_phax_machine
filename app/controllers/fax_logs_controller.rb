class FaxLogsController < ApplicationController
	include SessionsHelper
	before_action :set_phaxio_creds, :set_organization_or_organizations, :set_fax_numbers, :set_users

	def index
		options = FaxLog.build_options(current_user, filtering_params)
		if is_admin?
			fax_log = FaxLog.get_faxes(current_user, options)
		else
			options[:tag] = is_manager? ? {sender_organization_fax_tag: @organization.fax_tag} : {sender_email_fax_tag: current_user.fax_tag}
			fax_log = FaxLog.get_faxes(current_user, options, @fax_numbers)
		end

		if is_admin?
			FaxLog.add_all_attribute_to_hashes( [@fax_numbers, @organizations] )
			@sorted_faxes = FaxLog.format_faxes(current_user, fax_log, @organizations, @fax_numbers, @users)
		else
			FaxLog.add_all_attribute_to_hashes( [@users, @fax_numbers] )
			@sorted_faxes = FaxLog.format_faxes(current_user, fax_log, @fax_numbers, @organization, @users)
		end

		respond_to do |format|
			format.html {}
			format.js {}
		end
	end

	# create in this controller is for user-designated filtering
	def create
		options = FaxLog.build_options(current_user, filtering_params)
		options[:per_page] = 1000
		p options
		fax_log = FaxLog.get_faxes(current_user, options, @fax_numbers)

		if is_admin?
			FaxLog.add_all_attribute_to_hashes([@fax_numbers, @organizations])
			@sorted_faxes = FaxLog.format_faxes(current_user, fax_log, @organizations, @fax_numbers)
		else
			FaxLog.add_all_attribute_to_hashes( [@users, @fax_numbers] )
			@sorted_faxes = FaxLog.format_faxes(current_user, fax_log, @organization, @fax_numbers, @users)
		end

		respond_to do |format|
			format.html {}
			format.js {}
			format.json { render json: @sorted_faxes }
		end
	end

	private
		def set_phaxio_creds
			Fax.set_phaxio_creds
		end

		def filtering_params
			if params[:fax_log]
				params.require(:fax_log).permit(:start_time, :end_time, :fax_number, :organization, :user, :status)
			else
				params = { :fax_log => {} } # creates an empty hash when none are supplied on first request
			end
		end

		# Create a hash to reference for Organizations. Prevents program from querying the database constantly
		def set_organization_or_organizations
			if is_admin?
				@organizations = {}
				Organization.all.each { |organization_obj| FaxLog.create_orgs_hash(@organizations, organization_obj) }
			elsif is_manager?
				# Eager load associated users if manager, otherwise don't if a generic user is looking 
				@organization = Organization.includes(:users).find(current_user.organization_id)
			else
				@organization = Organization.find(current_user.organization_id)
			end
		end

		# Gets all Fax Numbers w/an associated Organization
		def set_fax_numbers
			@fax_numbers = {}
			if is_admin?
				FaxNumber.where.not(organization_id: nil).all.each { |fax_number_obj| FaxLog.create_fax_nums_hash(@fax_numbers, fax_number_obj) }
			else
				# Isolate Fax Numbers w/the found organization's ID
				FaxNumber.where({ organization_id: @organization.id }).each { |fax_num_obj| FaxLog.create_fax_nums_hash(@fax_numbers, fax_num_obj) }
			end
		end

		# Get users in an Organization is viewer is Manager, otherwise just use the current user.
		def set_users
			return if is_admin?
			@users = {}
			criteria_array = is_manager? ? @organization.users : [current_user] # current_user is in array for iterating/code reuse
			criteria_array.each_with_index { |user_obj, index| FaxLog.create_users_hash(@users, user_obj, index) }
		end
end