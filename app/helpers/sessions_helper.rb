module SessionsHelper
	def login(user)
		return false if user.id.nil?
		session[:user_id] = user.id
	end

	def current_user
		return if session[:user_id].nil?
		@current_user ||= User.find(session[:user_id])
	end

	def logged_in?
		!!current_user
	end
	
	def authorized?(input_object)
		return false if current_user.nil?
		current_user.id == input_object[:id].to_i || is_admin?
	end

	def is_admin?
		return false if current_user.nil?
		current_user.type == "Admin"
	end

	def is_client_manager? #allows admins as well
		return false if current_user.nil?
		current_user.type == "ClientManager" || is_admin?
	end

	def verify_is_admin
		if !is_admin?
			flash[:alert] = "Permission denied."
			redirect_to root_path
		end
	end
end