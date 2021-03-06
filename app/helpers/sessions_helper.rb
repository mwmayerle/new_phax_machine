module SessionsHelper
	# authorized? accepts an object and an attribute(should be an id) to compare against the current_user's id
	def authorized?(input_object, attribute)
		return false if current_user.nil?
		current_user.id == input_object[attribute].to_i || is_admin?
	end

	def is_admin?
		return false if current_user.nil?
		current_user.user_permission.permission == UserPermission::ADMIN
	end

	def is_manager? #allows admins as well
		return false if current_user.nil?
		current_user.user_permission.permission == UserPermission::MANAGER || is_admin?
	end

	def verify_is_admin
		if !is_admin?
			flash[:alert] = ApplicationController::DENIED
			redirect_to root_path
		end
	end

	def current_logo
		@current_logo = session[:logo_url]
		@current_logo ||= LogoLink.first.logo_url if LogoLink.first
	end

	def verify_is_manager_or_admin
		if !is_manager?
			flash[:alert] = ApplicationController::DENIED
			redirect_to root_path
		end
	end
end