module SessionsHelper
	def login(user)
		session[:user_id] = user.id
	end

	def current_user
		return if session[:user_id].nil?
		@current_user ||= User.find(session[:user_id])
	end

	def authorized?(session_params)
		current_user.id == session_params[:id].to_i
	end

	def logged_in?
		!!current_user
	end

	def is_admin?
		current_user.type == "Admin"
	end

	def is_client_manager?
		current_user.type == "ClientManager"
	end
end