class FaxNumbersController < ApplicationController
	include SessionsHelper
	
	before_action :verify_is_admin, only: [:index]
	before_action :set_fax_number, only: [:edit, :update]
	before_action :verify_authorized, only: [:edit, :update]

	def index
		@fax_numbers = FaxNumber.format_and_retrieve_fax_numbers_from_api
	end

	def edit
		current_user.type == "ClientManager" ? @clients = nil : @clients = Client.all
		@fax_number.unused_client_emails = FaxNumber.get_unused_client_emails(@fax_number)
	end

	def update
		original_client = @fax_number.client
		param_filter_type = current_user.type =="ClientManager" ? client_manager_fax_number_params : admin_fax_number_params
		if @fax_number.update_attributes(param_filter_type)
			# this 'if block' spoofs the "email[:to_remove]" portion of params by creating and passing in a similar hash
			if original_client != @fax_number.client
				@fax_number.update(fax_number_label: "Unallocated", fax_number_display_label: "Unlabeled")
				original_client_email_ids = {}
				original_client.emails.each { |email| original_client_email_ids[email.id] = 'on' }
				remove_email_associations(original_client_email_ids, @fax_number)
			end
			unless params[:emails].nil?
				add_email_associations(email_association_params[:to_add], @fax_number) if params[:emails][:to_add]
				remove_email_associations(email_association_params[:to_remove], @fax_number) if params[:emails][:to_remove]
			end
			flash[:notice] = "Changes successfully saved."
			redirect_to(client_path(id: original_client.id))
		else
			flash[:alert] = @fax_number.errors.full_messages.pop
			render :edit
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
			param_input.keys.each { |email_object_id| fax_number_object.emails << Email.find(email_object_id.to_i) }
		end

		def remove_email_associations(param_input, fax_number_object)
			param_input.keys.each { |email_object_id| FaxNumberEmail.where( { email_id: email_object_id } ).destroy_all }
		end

		def verify_authorized
			if !authorized?(@fax_number.client, :client_manager_id)
				flash[:alert] = "Permission denied."
				redirect_to root_path
			end
		end
end