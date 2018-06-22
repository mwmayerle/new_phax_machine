class UsersController < ApplicationController
	include SessionsHelper

	before_action :set_user, only: [:show]
	before_action :verify_is_admin, only: [:invite_and_create_client_manager]


	def index
	end

	def show
	end

	def create
		User.create(user_params)
	end

	private
		def set_user
			@user ||= User.find(params[:id])
		end

		def user_params
			params.require(:user).permit!
		end
end