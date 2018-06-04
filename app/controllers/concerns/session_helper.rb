module SessionsHelper
	def login(user)
		session[:user_id] = user.id
	end

	def logout
		session[:user_id] = nil
	end

	def current_user
		return if session[:user_id].nil?
		@current_user ||= User.find(session[:user_id])
	end

	def logged_in?
		!!current_user
	end

	def is_admin?
		current_user.is_admin
	end

	def is_group_leader?
		current_user.is_group_leader
	end
end