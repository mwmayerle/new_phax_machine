class ReadmesController < ApplicationController
	include SessionsHelper

	def show
		case permission
			
		when UserPermission::USER
			render(:user_readme)
		when UserPermission::MANAGER
			render(:manager_readme)
		when UserPermission::ADMIN
			render(:admin_readme)
		else
			flash[:alert] = ApplicationController::DENIED
			redirect_to(root_path) # For if nobody is logged in
		end
	end

	private
		def permission
			return false if !user_signed_in?
			current_user.user_permission.permission
		end
end
