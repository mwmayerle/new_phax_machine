class FaxLogsController < ApplicationController
	include SessionsHelper
	before_action :set_phaxio_creds, :set_organization_or_organizations, :set_fax_numbers, :set_users

	# this method is for the initial page load 
	def index

		initial_filtering_params = filtering_params
		initial_filtering_params[:fax_number] = 'all'
		options = FaxLog.build_options(current_user, filtering_params, @organizations, @users, @fax_numbers)
		options[:per_page] = 20

		if is_admin?
			initial_fax_data = FaxLog.get_faxes(current_user, options, initial_filtering_params)
			FaxLog.add_all_attribute_to_hashes( [@fax_numbers, @organizations] )
			all_faxes = FaxLog.sort_faxes(initial_fax_data) if initial_fax_data != []
			@sorted_faxes = FaxLog.format_faxes(current_user, all_faxes.take(20), @organizations, @fax_numbers, @users)
		else
			options[:tag] = is_manager? ? { sender_organization_fax_tag: @organizations.keys[0] } : { sender_email_fax_tag: current_user.fax_tag }
			initial_fax_data = FaxLog.get_faxes(current_user, options, initial_filtering_params, @users, @fax_numbers, @organizations)
			FaxLog.add_all_attribute_to_hashes( [@users, @fax_numbers] )
			all_faxes = FaxLog.sort_faxes(initial_fax_data)
			@sorted_faxes = FaxLog.format_faxes(current_user, all_faxes.take(20), @fax_numbers, @organizations, @users)
		end
	end

	# create method in this controller is for user-designated filtering after the initial page load
	def create
		options = FaxLog.build_options(current_user, filtering_params, @organizations, @users, @fax_numbers)
		options[:per_page] = 1000
		initial_fax_data = FaxLog.get_faxes(current_user, options, filtering_params, @users, @fax_numbers, @organizations)
		if is_admin?
			FaxLog.add_all_attribute_to_hashes( [@fax_numbers, @organizations] )
			all_faxes = FaxLog.sort_faxes(initial_fax_data)
			@sorted_faxes = FaxLog.format_faxes(current_user, all_faxes, @organizations, @fax_numbers, @users)
		else
			all_faxes = FaxLog.sort_faxes(initial_fax_data)
			FaxLog.add_all_attribute_to_hashes( [@users, @fax_numbers] )
			@sorted_faxes = FaxLog.format_faxes(current_user, all_faxes, @organizations, @fax_numbers, @users)
		end
		
		respond_to do |format|
			format.html
			format.js
			format.json { render :json => @sorted_faxes }
		end
	end

	def download
		options = FaxLog.build_options(current_user, filtering_params, @organizations, @users, @fax_numbers)
		info = Fax.get_fax_information(download_fax_params)
		if is_admin?
			can_download = true
		elsif is_manager?
			if info.direction == 'received'
				fax_nums = current_user.organization.user_fax_numbers.map { |user_fax_num| user_fax_num.fax_number }.uniq
				fax_nums = fax_nums.select { |fax_num| fax_num.org_switched_at.to_datetime < info.completed_at.to_datetime }
					.map { |fax_number| fax_number.fax_number }
				can_download = fax_nums.include?(info.to_number) || fax_nums.include?(info.from_number)
			else
				can_download = current_user.organization.fax_tag == info.tags[:sender_organization_fax_tag]
			end
		else #generic user
			if info.direction == 'received'
				fax_nums = current_user.user_fax_numbers.map { |user_fax_num| user_fax_num.fax_number }.uniq
				fax_nums = fax_nums.select { |fax_num| fax_num.org_switched_at.to_datetime < info.completed_at.to_datetime }
					.map { |fax_number| fax_number.fax_number }
				can_download = fax_nums.include?(info.to_number) || fax_nums.include?(info.from_number)
			else
				can_download = current_user.fax_tag == info.tags[:sender_email_fax_tag]
			end
		end

		if can_download
			api_response = Fax.download_file(download_fax_params)
			if api_response.is_a?(String)
	   		flash[:alert] = api_response
	   		redirect_to(fax_logs_path)
	   	else
	   		filepath = api_response.path
	   		filename = "Fax-#{download_fax_params}.pdf"
	   		send_file(filepath, filename: filename, type: :pdf, disposition: "attachment")
	   	end
		else
			flash[:alert] = "Problem accessing file"
			# render :body => nil, :status => :unauthorized
		end
	end

	private
		def set_phaxio_creds
			Fax.set_phaxio_creds
		end

		def download_fax_params
			params.require(:fax_id)
		end

		def filtering_params
			if params[:fax_log]
				params.require(:fax_log).permit(:start_time, :end_time, :fax_number, :organization, :user, :status)
			else
				params = { :fax_log => {} } # for the first request on page load
			end
		end

		# Create a hash of Organization object data to reference later. Prevents program from querying the database constantly
		def set_organization_or_organizations
			# Sends logged out user to root if they access /fax_logs while logged out.
			redirect_to(root_path) and return if !user_signed_in?

			@organizations = {}
			if is_admin?
				if is_all_or_is_nil?(filtering_params[:organization])
					organization_objects = Organization.all.with_deleted
				else
					organization_objects = Organization.with_deleted.where(fax_tag: filtering_params[:organization])
				end
			# AR's .find() is used b/c is stops on the first result, and then added to an array for code-reuse
			elsif is_manager?	# Eager load associated users if manager, otherwise don't if a generic user is looking 
				organization_objects = []
				organization_objects << Organization.includes(:users).find(current_user.organization_id)
			else
				organization_objects = []
				organization_objects << Organization.find(current_user.organization_id)
			end
			organization_objects.each { |organization_obj| FaxLog.create_orgs_hash(@organizations, organization_obj) }
		end

		# Get a hash of Fax Number object data based on permissions and filtering requests
		def set_fax_numbers
			@fax_numbers = {}
			if is_admin?
				# Get every fax number in the database
				if is_all_or_is_nil?(filtering_params[:fax_number])
					fax_num_from_db = FaxNumber.with_deleted.includes(:organization).where.not(organization_id: nil)
				# Get every fax number linked to a specified organization
				elsif filtering_params[:fax_number] == "all-linked"
					fax_num_from_db = FaxNumber.with_deleted.includes(:organization)
						.where(organization_id: @organizations[filtering_params[:organization]][:org_id])
				# Get a specific fax number
				else
					fax_num_from_db = FaxNumber.with_deleted.includes(:organization).where(fax_number: filtering_params[:fax_number])
				end
				fax_num_from_db.each { |fax_number_obj| FaxLog.create_fax_nums_hash(@fax_numbers, fax_number_obj) }

			elsif is_manager?
				# Isolate Fax Numbers w/the found organization's ID
				if is_all_or_is_nil?(filtering_params[:fax_number])
					fax_num_from_db = FaxNumber.with_deleted.includes(:organization).where({ organization_id: current_user.organization_id })
				# Isolate a specific fax number
				else
					fax_num_from_db = FaxNumber.with_deleted.includes(:organization).where(fax_number: filtering_params[:fax_number])
				end

				fax_num_from_db.each { |fax_number_obj| FaxLog.create_fax_nums_hash(@fax_numbers, fax_number_obj) }

			else # generic user
				if is_all_or_is_nil?(filtering_params[:fax_number])
					user_fax_nums = UserFaxNumber.includes(:fax_number)
						.where(user_id: current_user.id)
						.map { |user_fax_num| user_fax_num.fax_number }

					user_fax_nums.each { |user_fax_num| FaxLog.create_fax_nums_hash(@fax_numbers, user_fax_num) }
				else
					FaxLog.create_fax_nums_hash(@fax_numbers, FaxNumber.includes(:organization)
						.find_by(fax_number: filtering_params[:fax_number]))

				end
			end
		end

		# Admins can get to everything.
		# Get users in an Organization if viewer is a Manager, otherwise just use the current user.
		# UserPermission objects are used in some way in this method because a user without an associated permission object
		#  (invited but hasn't set their password) will fail 'is_manager?', 'is_admin?', etc.
		def set_users
			@users = {}
			if is_admin?
				criteria_array = User.includes([:organization, :user_permission]).all.with_deleted.select do |user|
					user.user_permission && user.organization_id
				end
			else
				# current_user is in an array for iterating/code reuse
				if is_manager?
					criteria_array = User.includes([:organization, :user_permission])
						.with_deleted
						.where(organization_id: current_user.organization_id)
						.select { |user| user.user_permission }
				else
					criteria_array = [current_user]
				end
			end
			criteria_array.each_with_index { |user_obj, index| FaxLog.create_users_hash(@users, user_obj, index) }
		end

		def is_all_or_is_nil?(params_input)
			params_input == "all" || params_input.nil?
		end
end