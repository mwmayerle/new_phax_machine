class UserEmailsController < ApplicationController
	include SessionsHelper

	before_action :set_user_email, only: [:edit, :update]
	before_action :set_client, only: [:new]
	before_action :verify_is_client_manager_or_admin, only: [:new, :create]

	def new
		if authorized?(@fax_number.client, :client_manager_id)
			@user_email = UserEmail.new(client_id: @fax_number.client_id)
			@existing_emails = @fax_number.user_emails
			render :new
		else
			flash[:alert] = DENIED
			redirect_to root_path
		end
	end

	def create
		@client = Client.find(params[:user_email][:client_id])
		
		if @client && authorized?(@client, :client_manager_id)
			@user_email = UserEmail.new(user_email_params)

			if @user_email.valid?
				@client.user_emails << @user_email
				flash[:notice] = "Email successfully created."
			else
				flash[:alert] = @user_email.errors.full_messages.pop
			end

		else
			flash[:alert] = @client.errors.full_messages.pop
		end
		redirect_to client_path(@client)
	end

	def edit
	end

	def update
		if @user_email.update_attributes(user_email_params)
			# Line below updates the User object's email attribute, which behaves like and mimics a username
			@user_email.user.update_attributes(email: user_email_params[:email_address]) if @user_email.user
			flash[:notice] = "Email successfully edited."
			redirect_to client_path(@user_email.client)
		else
			flash[:notice] = @user_email.errors.full_messages.pop
			redirect_to :edit
		end
	end

	private
		def set_user_email
			@user_email ||= UserEmail.find(params[:id])
		end

		def set_client
			@client ||= Client.find(params[:id])
		end

		def user_email_params
			params.require(:user_email).permit(:id, :email_address, :client_id, :caller_id_number, :user_id)
		end
end