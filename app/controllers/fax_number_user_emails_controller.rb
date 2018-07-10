class FaxNumberUserEmailsController < ApplicationController
	include SessionsHelper

	before_action :set_fax_number, only: [:edit, :update]
	before_action :verify_authorized, only: [:edit, :update]

	def edit
		@fax_number.unused_client_emails = FaxNumber.get_unused_client_emails(@fax_number) if @fax_number.client
	end

	def update
		unless params[:user_emails].nil?
			add_user_email_associations(user_email_association_params[:to_add], @fax_number) if params[:user_emails][:to_add]
			remove_user_email_associations(user_email_association_params[:to_remove], @fax_number) if params[:user_emails][:to_remove]
		end

		flash[:notice] = "Changes successfully saved."
		redirect_to(client_path(@fax_number.client.id))
	end

	private 
		def set_fax_number
			@fax_number ||= FaxNumber.find(params[:id])
		end

		def user_email_association_params
			params.require(:user_emails).permit(:to_add => {}, :to_remove => {})
		end

		def add_user_email_associations(param_input, fax_number_object) # equivalent of @fax_number << UserEmail
			param_input.keys.each { |user_email_object_id| fax_number_object.user_emails << UserEmail.find(user_email_object_id.to_i) }
		end

		def remove_user_email_associations(param_input, fax_number_object)
			param_input.keys.each { |user_email_object_id| FaxNumberUserEmail.where( { user_email_id: user_email_object_id } ).destroy_all }
		end

		def verify_authorized
			if !authorized?(@fax_number.client, :client_manager_id)
				flash[:alert] = DENIED
				redirect_to root_path
			end
		end
end