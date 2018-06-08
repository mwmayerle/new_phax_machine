module SessionsHelper
	def login(user)
		return false if user.id.nil?
		session[:user_id] = user.id
	end

	def current_user
		return if session[:user_id].nil?
		@current_user ||= User.find(session[:user_id])
	end

	def authorized?(input)
		return false if current_user.nil?
		current_user.id == input[:id].to_i
	end

	def logged_in?
		!!current_user
	end

	def is_admin?
		return false if current_user.nil?
		current_user.type == "Admin"
	end

	def is_client_manager?
		return false if current_user.nil?
		current_user.type == "ClientManager"
	end
end