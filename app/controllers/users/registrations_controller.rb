# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
	include SessionsHelper
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  	before_action :verify_permissions
  	prepend_before_action :require_no_authentication, only: :cancel

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
  	p sign_up_params
    build_resource(sign_up_params)
    resource.save
    yield resource if block_given?
    if resource.persisted?
    	client = Client.find(resource.client_id)
    	client.update(client_manager_id: resource.id)
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
    end
    if is_admin?
    	redirect_to clients_path
  	else
    	redirect_to client_path(current_user.client)
  	end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
  
  def verify_permissions
  	if !is_admin? && sign_up_params[:type] == User::CLIENT_MANAGER || !is_client_manager?
  		flash[:alert] = "Permission denied."
  		redirect_to_root_path
  	end
  end
end
