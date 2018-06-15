class EmailsController < ApplicationController
	include SessionsHelper

	before_action :set_email, only: [:edit, :update]
	before_action :set_fax_number, only: [:new]
	before_action :verify_is_client_manager_or_admin, only: [:new, :create]

	def new
		if authorized?(@fax_number.client, :client_manager_id)
			@email = Email.new(client_id: @fax_number.client_id)
			@existing_emails = @fax_number.emails
			render :new
		else
			flash[:alert] = "Permission denied."
			redirect_to root_path
		end
	end

	def create
		@fax_number = FaxNumber.find(params[:email][:fax_number_id])
		if @fax_number && authorized?(@fax_number.client, :client_manager_id)
			@email = Email.new(email_params)
			if @email.valid?
				@fax_number.emails << @email
				flash[:notice] = "Email successfully created."
				redirect_to client_path(id: @fax_number.client.id)
			else
				flash[:alert] = @email.errors.full_messages.pop
				render :new
			end
		else
			flash[:alert] = @fax_number.errors.full_messages.pop
			render :new
		end
	end

	def edit
	end

	def update
		if @email.update_attributes(email_params)
			flash[:notice] = "Email successfully edited."
			redirect_to client_path(@email.client)
		else
			flash[:notice] = email.errors.full_messages.pop
			redirect_to :edit
		end
	end

	private
		def set_email
			@email ||= Email.find(params[:id])
		end

		def set_fax_number
			@fax_number ||= FaxNumber.find(params[:id])
		end

		def email_params
			params.require(:email).permit(:id, :email, :client_id, :caller_id_number)
		end

		def verify_is_client_manager_or_admin
			unless is_client_manager? && authorized?(@email.client, :client_manager_id)
				flash[:alert] = "Permission denied."
				redirect_to root_path
			end
		end
end