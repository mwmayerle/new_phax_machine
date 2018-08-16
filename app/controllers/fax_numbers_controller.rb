class FaxNumbersController < ApplicationController
	include SessionsHelper
	
	before_action :verify_is_admin, only: [:index]
	before_action :set_fax_number, only: [:edit, :update]
	before_action :verify_authorized

	# Table of all fax numbers in your account
	def index
		@area_codes = FaxNumber.get_area_code_list
		@states = FaxNumber.create_states_for_numbers(@area_codes)
		@fax_numbers = FaxNumber.format_and_retrieve_fax_numbers_from_api
	end

	 # Post request for purchasing the new number
	def create
		api_response = FaxNumber.provision(provision_number_params[:area_code])
		if api_response.raw_data
			flash[:notice] = "Number Provisioned Successfully"
			redirect_to fax_numbers_path
		else
			flash[:alert] = "Something went wrong"
			render :new
		end
	end

	# Form for editing a fax number
	def edit
		@user = User.new
		@organizations = Organization.order(label: :asc) if is_admin?
	end

	def update #LOOK AT THIS TO ENSURE IT'S STILL OKAY
		param_filter_type = is_admin? ? admin_fax_number_params : manager_fax_number_params
		
		original_organization = @fax_number.organization

		if @fax_number.update_attributes(param_filter_type)
			# this if block spoofs the "user[:to_remove]" portion of params by creating and passing in a similar hash
			if original_organization && original_organization != @fax_number.organization
				@fax_number.update_attributes(manager_label: nil, organization_id: nil) # <--untested added org_id here 08/15/18
				original_organization_user_ids = {}
				original_organization.users.each { |user| original_organization_user_ids[user.id] = 'on' }
				remove_user_associations(original_organization_user_ids, @fax_number)
			end

			flash[:notice] = "Changes successfully saved."

			# This ternary is for editing a fax number's label before the Organization object is created
			@fax_number.organization ? redirect_to(organization_path(@fax_number.organization)) : redirect_to(fax_numbers_path)
		else
			flash[:alert] = @fax_number.errors.full_messages.pop
			redirect_to(edit_fax_number_path(@fax_number))
		end
	end

	private
		def set_fax_number
			@fax_number ||= FaxNumber.find(params[:id])
		end

		def admin_fax_number_params
			params.require(:fax_number).permit(:fax_number, :label, :id, :manager_label, :organization_id)
		end

		def manager_fax_number_params
			params.require(:fax_number).permit(:id, :manager_label)
		end

		def provision_number_params
			params.require(:fax_number).permit(:area_code)
		end

		def list_area_code_params
			params.require(:fax_number).permit(:area_code, :toll_free, :state)
		end

		def remove_user_associations(param_input, fax_number_object)
			param_input.keys.each { |user_object_id| UserFaxNumber.where( { user_id: user_object_id } ).destroy_all }
		end

		def verify_authorized
			return if is_admin?
			if !authorized?(@fax_number.manager, :id)
				flash[:alert] = DENIED
				redirect_to root_path
			end
		end
end