# frozen_string_literal: true
class Users::PasswordsController < Devise::PasswordsController
  # GET /resource/password/set_new_user_password?reset_password_token=abcdef
  def set_new_user_password
    self.resource = resource_class.new
    set_minimum_password_length
    resource.reset_password_token = params[:reset_password_token]
  end

  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)

      if Devise.sign_in_after_reset_password

      	if params[:user][:new_user]
      		flash[:notice] = "Welcome to Phax Machine #{resource.email}. You have been logged in."
      	else
        	flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
        	set_flash_message!(:notice, flash_message)
        end

        sign_in(resource_name, resource)
      else
        set_flash_message!(:notice, :updated_not_active)
      end
      
      respond_with resource, location: after_resetting_password_path_for(resource)
    else
      set_minimum_password_length
      respond_with resource
    end
  end

end
