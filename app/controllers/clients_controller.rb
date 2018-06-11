class ClientsController < ApplicationController
	include SessionsHelper
	
	before_action :verify_is_client_manager_or_admin
	before_action :set_client, only: [:edit, :update, :destroy]

	def new
		@client = Client.new
	end

	def create
	end

	def edit
	end

	def update
	end

	def destroy
		redirect_to :index if !is_admin?
	end

	private
		def verify_is_client_manager_or_admin
			if !is_client_manager? #is_client_manager? is in SessionsHelper, it allows Admin the same functions as a client_manager
				flash[:alert] = "Permission denied."
				redirect_to root_path
			end
		end

		def set_client
			@client ||= Client.find(params[:id]) #MAKE STRONG PARAMS FOR THIS LATER
		end
end