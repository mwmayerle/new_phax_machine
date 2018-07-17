class FaxNumbersController < ApplicationController
	include SessionsHelper
	
	before_action :verify_is_admin, only: [:index]
	before_action :set_fax_number, only: [:edit, :update]
	before_action :verify_authorized, only: [:edit, :update]

	def index
		@fax_numbers = FaxNumber.format_and_retrieve_fax_numbers_from_api
	end

	def edit
		@user = User.new
		@clients = Client.order(client_label: :asc) if is_admin?
	end

	def update
		param_filter_type = is_admin? ? admin_fax_number_params : client_manager_fax_number_params
		
		original_client = @fax_number.client

		if @fax_number.update_attributes(param_filter_type)
			# this if block spoofs the "email[:to_remove]" portion of params by creating and passing in a similar hash
			if original_client && original_client != @fax_number.client
				@fax_number.update_attributes(fax_number_display_label: nil)
				original_client_user_email_ids = {}
				original_client.user_emails.each { |user_email| original_client_user_email_ids[user_email.id] = 'on' }
				remove_user_email_associations(original_client_user_email_ids, @fax_number)
			end

			flash[:notice] = "Changes successfully saved."
			# This ternary is for editing a fax number's label before the client is created
			@fax_number.client ? redirect_to(client_path(@fax_number.client)) : redirect_to(fax_numbers_path)
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

		def remove_user_email_associations(param_input, fax_number_object)
			param_input.keys.each { |user_object_id| UserFaxNumber.where( { user_id: user_object_id } ).destroy_all }
		end

		def verify_authorized
			return if is_admin?
			if !authorized?(@fax_number.manager, :manager_id)
				flash[:alert] = DENIED
				redirect_to root_path
			end
		end
end