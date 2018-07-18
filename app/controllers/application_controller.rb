class ApplicationController < ActionController::Base
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
	    	:sign_up_permission
	    ])
	  end
end