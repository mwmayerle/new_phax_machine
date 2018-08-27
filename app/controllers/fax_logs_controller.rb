class FaxLogsController < ApplicationController
	include SessionsHelper
	before_action :set_phaxio_creds, :set_organization_or_organizations, :set_fax_numbers, :set_users

	def index
		options = FaxLog.build_options(current_user, filtering_params)
		if is_admin?
			initial_fax_data = FaxLog.get_faxes(current_user, options)
		else
			options[:tag] = is_manager? ? { sender_organization_fax_tag: @organization.fax_tag } : { sender_email_fax_tag: current_user.fax_tag }
			initial_fax_data = FaxLog.get_faxes(current_user, options, @fax_numbers)
		end

		if is_admin?
			FaxLog.add_all_attribute_to_hashes( [@fax_numbers, @organizations] )
			@sorted_faxes = FaxLog.format_faxes(current_user, initial_fax_data, @organizations, @fax_numbers, @users)
		else
			FaxLog.add_all_attribute_to_hashes( [@users, @fax_numbers] )
			@sorted_faxes = FaxLog.format_faxes(current_user, initial_fax_data, @fax_numbers, @organization, @users)
		end
	end

	# create method in this controller is for user-designated filtering
	def create
		options = FaxLog.build_options(current_user, filtering_params)
		options[:per_page] = 1000

		initial_fax_data = FaxLog.get_faxes(current_user, options, @fax_numbers)

		if is_admin?
			FaxLog.add_all_attribute_to_hashes([@fax_numbers, @organizations])
			@sorted_faxes = FaxLog.format_faxes(current_user, initial_fax_data, @organizations, @fax_numbers, @users)
		else
			FaxLog.add_all_attribute_to_hashes( [@users, @fax_numbers] )
			@sorted_faxes = FaxLog.format_faxes(current_user, initial_fax_data, @organization, @fax_numbers, @users)
		end

		respond_to do |format|
			format.html
			format.js
			format.json { render :json => @sorted_faxes }
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
				if filtering_params[:organization] == "all" || filtering_params[:organization].nil?
					Organization.all.each { |organization_obj| FaxLog.create_orgs_hash(@organizations, organization_obj) }
				else
					Organization.where(fax_tag: filtering_params[:organization]).each do |organization_obj|
						FaxLog.create_orgs_hash(@organizations, organization_obj)
					end
				end
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
				
				if filtering_params[:fax_number] == "all" || filtering_params[:fax_number].nil? # Get every fax number in the database
					FaxNumber.where.not(organization_id: nil).each do |fax_number_obj|
						FaxLog.create_fax_nums_hash(@fax_numbers, fax_number_obj)
					end
				elsif filtering_params[:fax_number] == "all-linked" # Get every fax number linked to a specified organization
					FaxNumber.where(organization_id: @organizations[filtering_params[:organization]]['org_id']).each do |fax_number_obj|
						FaxLog.create_fax_nums_hash(@fax_numbers, fax_number_obj)
					end
				else # Get a specific fax number
					FaxNumber.where(fax_number: filtering_params[:fax_number]).each do |fax_number_obj|
						FaxLog.create_fax_nums_hash(@fax_numbers, fax_number_obj)
					end
				end

			else # manager or user is makign the request
				if filtering_params[:fax_number] == "all"
					# Isolate Fax Numbers w/the found organization's ID
					FaxNumber.where({ organization_id: @organization.id }).each do |fax_num_obj|
						FaxLog.create_fax_nums_hash(@fax_numbers, fax_num_obj)
					end
				else
					# Isolate a specific fax number
					FaxNumber.where(fax_number: filtering_params[:fax_number]).each do |fax_num_obj|
						FaxLog.create_fax_nums_hash(@fax_numbers, fax_num_obj)
					end
				end

			end
		end

		# Get users in an Organization is viewer is Manager, otherwise just use the current user.
		def set_users
			@users = {}
			if is_admin?
				User.all.each_with_index { |user_obj, index| FaxLog.create_users_hash(@users, user_obj, index) if user_obj.id != 1 }
			else
				criteria_array = is_manager? ? @organization.users : [current_user] # current_user is in array for iterating/code reuse
				criteria_array.each_with_index { |user_obj, index| FaxLog.create_users_hash(@users, user_obj, index) }
			end
		end
end