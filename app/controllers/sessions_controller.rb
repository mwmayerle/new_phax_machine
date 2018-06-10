class SessionsController < ApplicationController
	include SessionsHelper #in helpers and not concerns

	def index
	end
	
	def new
		if logged_in?
			flash[:alert] = "You must log out before you can log in."
			redirect_to root_path
		end
		@user = User.new
	end

	def create
		user = User.find_by(username: session_params[:username])
		if user && user.authenticate(session_params[:password])
			login(user)
			flash.now[:notice] = "Welcome #{user.username}."
			render :template => "users/show"
		else
			flash.now[:alert] = "Invalid username or password. Please try again."
			render :new
		end
	end

	def destroy
		if logged_in? && authorized?(session_params)
			session[:user_id] = nil
			flash[:notice] = "You've been logged out."
		else
			flash.now[:alert] = "Something went wrong."
		end
		redirect_to root_path
	end

	private
		def session_params
			params.require(:session).permit(:password, :username, :id)
		end
end