class UsersController < ApplicationController
	include SessionsHelper

	before_action :set_user, only: [:show]

	def index
	end

	def show
	end

	# def create
		# go to /users/registrations_controller.rb
	# end

	private
		def set_user
			@user ||= User.find(params[:id])
		end

		def user_params
			params.require(:user).permit(:id, :type, :client_id, :email)
		end

		def verify_is_client_manager_or_admin
			if !is_client_manager?
				flash[:alert] = 'Permission denied.'
				redirect_to root_path
			end
		end
end