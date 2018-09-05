class FaxLogsController < ApplicationController
	include SessionsHelper
	before_action :set_phaxio_creds, :set_organization_or_organizations, :set_fax_numbers, :set_users

	def index
		if is_admin?
			options = FaxLog.build_options(current_user, filtering_params, @organizations)
			initial_fax_data = FaxLog.get_faxes(current_user, options,)
			FaxLog.add_all_attribute_to_hashes( [@fax_numbers, @organizations] )
			@sorted_faxes = FaxLog.format_faxes(current_user, initial_fax_data, @organizations, @fax_numbers, @users)
		else
			options = FaxLog.build_options(current_user, filtering_params, @organization)
			options[:tag] = is_manager? ? { sender_organization_fax_tag: @organization.fax_tag } : { sender_email_fax_tag: current_user.fax_tag }
			initial_fax_data = FaxLog.get_faxes(current_user, options, @users, @fax_numbers)
			FaxLog.add_all_attribute_to_hashes( [@users, @fax_numbers] )
			@sorted_faxes = FaxLog.format_faxes(current_user, initial_fax_data, @fax_numbers, @organization, @users)
		end
	end

	# create method in this controller is for user-designated filtering
	def create
		options = FaxLog.build_options(current_user, filtering_params, @organization)
		options[:per_page] = 1000
		initial_fax_data = FaxLog.get_faxes(current_user, options, @users, @fax_numbers)

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
				# Get every fax number in the database
				if filtering_params[:fax_number] == "all" || filtering_params[:fax_number].nil?
					fax_num_from_db = FaxNumber.where.not(organization_id: nil)
				# Get every fax number linked to a specified organization
				elsif filtering_params[:fax_number] == "all-linked"
					fax_num_from_db = FaxNumber.where(organization_id: @organizations[filtering_params[:organization]]['org_id'])
				# Get a specific fax number
				else
					fax_num_from_db = FaxNumber.where(fax_number: filtering_params[:fax_number])
				end

				fax_num_from_db.each { |fax_number_obj| FaxLog.create_fax_nums_hash(@fax_numbers, fax_number_obj) }
			# manager or user is making the request
			elsif is_manager?
				# Isolate Fax Numbers w/the found organization's ID
				if filtering_params[:fax_number] == "all" || filtering_params[:fax_number].nil?
					fax_num_from_db = FaxNumber.where({ organization_id: @organization.id })
				# Isolate a specific fax number
				else
					fax_num_from_db = FaxNumber.where(fax_number: filtering_params[:fax_number])
				end

				fax_num_from_db.each { |fax_number_obj| FaxLog.create_fax_nums_hash(@fax_numbers, fax_number_obj) }

			else # generic user
				user_fax_num_objects = UserFaxNumber.includes(:fax_number).where(user_id: current_user.id)
				user_fax_nums = user_fax_num_objects.map { |user_fax_num| user_fax_num.fax_number }

				user_fax_nums.each do |user_fax_num|
					@fax_numbers[user_fax_num.fax_number] = { 'label' => current_user.organization.label }
					@fax_numbers[user_fax_num.fax_number]['org_created_at'] = current_user.organization.created_at
					@fax_numbers[user_fax_num.fax_number]['org_id'] = current_user.organization.id
				end
				@fax_numbers
			end
		end

		# Get users in an Organization is viewer is Manager, otherwise just use the current user.
		def set_users
			@users = {}
			if is_admin?
				User.all.each_with_index { |user_obj, index| FaxLog.create_users_hash(@users, user_obj, index) if user_obj.id != 1 }
			else
				criteria_array = is_manager? ? @organization.users : [current_user] # current_user is in an array for iterating/code reuse
				criteria_array.each_with_index { |user_obj, index| FaxLog.create_users_hash(@users, user_obj, index) }
			end
		end
end