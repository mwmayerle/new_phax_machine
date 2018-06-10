class UsersController < ApplicationController
	include SessionsHelper

	before_action :set_user, only: [:show]

	def admin_console
		redirect_to root_path if !is_admin?
	end

	def client_console
		redirect_to root_path if !is_client_manager?
	end

	def show
	end

	private
		def set_user
			@user ||= User.find(params[:id]) #MAKE THIS USE STRONG PARAMS LATER
		end
end
