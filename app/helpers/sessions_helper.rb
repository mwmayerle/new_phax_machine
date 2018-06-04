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
		current_user.is_admin
	end

	def is_group_leader?
		current_user.is_group_leader #this does not verify a user is the group leader of a particular group, just the ability to be one
	end
end