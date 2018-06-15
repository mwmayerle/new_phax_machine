class FaxNumbersController < ApplicationController
	include SessionsHelper
	
	before_action :verify_is_admin, only: [:index]
	before_action :set_fax_number, only: [:edit, :update]

	def index
		@fax_numbers = FaxNumber.format_and_retrieve_fax_numbers_from_api
	end

	def edit
		if authorized?(@fax_number.client, :client_manager_id)
			current_user.type == "ClientManager" ? @clients = nil : @clients = Client.all
			@fax_number.unused_client_emails = FaxNumber.get_unused_client_emails(@fax_number)
		else
			flash[:alert] = "Permission denied."
			redirect_to root_path
		end
	end

	def update
		if authorized?(@fax_number.client, :client_manager_id)
			param_filter_type = current_user.type =="ClientManager" ? client_manager_fax_number_params : admin_fax_number_params
			if @fax_number.update_attributes(param_filter_type)
				unless params[:emails].nil?
					add_email_associations(email_association_params[:to_add], @fax_number) if params[:emails][:to_add]
					remove_email_associations(email_association_params[:to_remove], @fax_number) if params[:emails][:to_remove]
				end
				flash[:notice] = "Changes successfully saved."
				is_admin? ? redirect_to(fax_numbers_path) : redirect_to(client_path(id: @fax_number.client_id))
			else
				flash[:alert] = @fax_number.errors.full_messages.pop
				render :edit
			end
		else
			flash[:alert] = "Permission denied."
			redirect_to root_path
		end
	end

	private
		def set_fax_number
			@fax_number ||= FaxNumber.find(params[:id])
		end

		def admin_fax_number_params
			params.require(:fax_number).permit(:fax_number, :fax_number_label, :id, :fax_number_display_label, :client_id)
		end

		def client_manager_fax_number_params
			params.require(:fax_number).permit(:id, :fax_number_display_label)
		end

		def email_association_params
			params.require(:emails).permit(:to_add => {}, :to_remove => {})
		end

		def add_email_associations(param_input, fax_number_object) #equivalent of @fax_number << Email
			param_input.each { |email_object_id, checkbox_on| fax_number_object.emails << Email.find(email_object_id.to_i) }
		end

		def remove_email_associations(param_input, fax_number_object)
			param_input.each do |email_object_id, checkbox_on| 
				email = Email.find(email_object_id)
				FaxNumberEmail.where( { email_id: email_object_id } ).destroy_all
			end
		end
end