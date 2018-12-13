class ApplicationController < ActionController::Base
	include SessionsHelper
	before_action :authenticate_user!, if: :devise_controller?
	before_action :configure_permitted_parameters, if: :devise_controller?

	DENIED = "Permission denied.".freeze

  protected
		def configure_permitted_parameters
	    devise_parameter_sanitizer.permit(:sign_up, keys: [
	    	:organization_id,
	    	:email,
	    	:id,
	    	:caller_id_number,
	    	:permission
	    ])
	    if is_admin?
	    	devise_parameter_sanitizer.permit(:account_update, keys: [:password, :password_confirmation, :current_password, :logo_url])
	    else
	    	devise_parameter_sanitizer.permit(:account_update, keys: [:password, :password_confirmation, :current_password])
	    end
	  end
end