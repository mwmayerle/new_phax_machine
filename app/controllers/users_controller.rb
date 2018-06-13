class UsersController < ApplicationController
	include SessionsHelper

	before_action :set_user, only: [:show]

	def new
	end

	def create
	end

	def show
	end

	def edit
	end

	def update
	end

	def destroy
	end

	private
		def set_user
			@user ||= User.find(params[:id])
		end
end
