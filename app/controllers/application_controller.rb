class ApplicationController < ActionController::Base
	# before_action :authenticate_user!
	before_action :configure_permitted_parameters, if: :devise_controller?
	DENIED = "Permission denied.".freeze

  protected
		def configure_permitted_parameters
	    devise_parameter_sanitizer.permit(:sign_up, keys: [:client_id, :email, :id, :type, :invite, :caller_id_number])
	  end
end
