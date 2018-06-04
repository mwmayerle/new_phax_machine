class SessionsController < ApplicationController
	include SessionsHelper

	def new
		@user = User.new
	end

	def create
		user = User.find_by(email: session_params[:email])
		if user && user.authenticate(session_params[:password])
			login(user)
			render :template => "users/show"
		else
			p "lol invalid"
			render :new
		end
	end

	def destroy

	end

	private
		def session_params
			params.require(:session).permit(:password, :email)
		end
end
