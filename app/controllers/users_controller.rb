class UsersController < ApplicationController
	include SessionsHelper

	before_action :verify_is_manager_or_admin
	before_action :set_user, only: [:edit, :update]
	

	# def create
		# go to /users/registrations_controller.rb
	# end

	# def destroy
		# go to /users/registrations_controller.rb
	# end

	def edit
	end
	
	# Users editing their passwords is done through the Devise registration controller. This
	# method is only for Admins or Managers to change a User's caller_id_number, email, or permission level 
	def update
		# Adding this to params now b/c Rails strong_params requires it and it's better to avoid the hidden field in the view
		original_permission = @user.user_permission.permission
		params[:user_permission] = { permission: original_permission } if params[:user_permission].nil?

		if @user.update_attributes(user_params)

			# Update user permissions if needed. Demote manager to normal user, promote a normal user
			# See if the user's original permission is different than the one provided
			if original_permission != permission_params[:permission] && original_permission
				UserPermission.find_by(user_id: @user.id).update_attributes(permission: permission_params[:permission])
				# Make manager_id nil in org if Manager was demoted
				if original_permission == UserPermission::MANAGER && is_admin?
					Organization.find(@user.organization_id).update_attributes(manager_id: nil)
				# Promote new Manager
				elsif original_permission == UserPermission::USER && is_admin?
					Organization.find(@user.organization_id).update_attributes(manager_id: @user.id)
				end
			end
			flash[:notice] = "User updated successfully!"
			redirect_to(organization_path(@user.organization))
		else
			flash[:alert] = @user.errors.full_messages.pop
			render :edit
		end
	end

	private
		def set_user
			@user ||= User.find(params[:id])
		end

		def user_params
			params.require(:user).permit(:caller_id_number, :email)
		end

		def permission_params
			params.require(:user_permission).permit(:permission)
		end

		def adjust_manager(organization_id, id)
			Organization.where(id: user.organization_id).update_attributes(manager_id: nil)
		end
end