class EmailsController < ApplicationController
	include SessionsHelper

	before_action :set_fax_number, only: [:new]

	def new
		if authorized?(@fax_number.client, :client_manager_id)
			@email = Email.new(client_id: @fax_number.client_id)
			@existing_emails = @fax_number.emails.select { |email| email.fax_number == @fax_number.fax_number }
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

	private
		def set_fax_number
			@fax_number ||= FaxNumber.find(params[:id])
		end

		def email_params
			params.require(:email).permit(:id, :email, :client_id, :fax_number)
		end
end