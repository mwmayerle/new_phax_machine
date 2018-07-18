# frozen_string_literal: true
class Users::RegistrationsController < Devise::RegistrationsController
	include SessionsHelper
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  	before_action :verify_fax_numbers, only: [:create, :destroy]
  	before_action :verify_permissions, only: [:create, :destroy]
  	prepend_before_action :require_no_authentication, only: :cancel

  # POST /resource
  def create
    build_resource(sign_up_params)
    yield resource if block_given?
    resource.save
    if resource.persisted?
	    user = User.find(resource.id)   
	    UserPermission.create(user_id: user.id, permission: resource.sign_up_permission)

	    # Sets Org's Manager as the newly created User if they're intended to be the Manager.
    	if user.reload.user_permission.permission == UserPermission::MANAGER
	    	organization = Organization.find(resource.organization_id)
	    	organization.update_attributes(manager_id: user.id)
	    end
	    
      if resource.active_for_authentication?
        flash[:notice] = "#{resource.email} has been invited."
      else
        flash[:notice] = "signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
      end

    else
    	flash[:alert] = resource.errors.full_messages.pop
      clean_up_passwords resource
      set_minimum_password_length
    end
		if resource
    	resource.sign_up_permission == UserPermission::USER ? redirect_to(organization_path(resource.organization)) : redirect_to(organizations_path)
    else
    	redirect_to(organization_path(sign_up_params[:organization_id]))
    end
  end

  # DELETE /resource
  def destroy
  	resource = User.find(params[:id])
		organization = current_user.organization.nil? ? organization.find(resource.organization.id) : current_user.organization
		# Removes organization_manager privileges
		organization.update_attributes(manager_id: nil) if resource.user_permission.permission == UserPermission::MANAGER

    resource.destroy
    flash[:notice] = "Access for #{resource.email} revoked"
    yield resource if block_given?
    redirect_to(organization_path(organization))
  end

  protected
	  def verify_permissions
	  	# Ensures a new admin cannot be created and that a manager can only be created by an admin
	  	if sign_up_params[:sign_up_permission] == UserPermission::USER
	  		verify_is_manager_or_admin
	  	elsif sign_up_params[:sign_up_permission] == UserPermission::MANAGER
	  		verify_is_admin
	  	else
	  		flash[:alert] = "Permission denied reeeeeeeeeeeeeeeeeeeeeeee."
	  		redirect_to(root_path)
	  	end
	  end

	  def verify_fax_numbers
	  	# Admins do not have an associated organization, otherwise compare the current_user.org.id to the desired caller_id_number
	  	if is_admin?
	  		existing_numbers = FaxNumber.where(fax_number: sign_up_params[:caller_id_number], organization_id: sign_up_params[:organization_id])
	  	elsif is_manager?
	  		existing_numbers = FaxNumber.where(fax_number: sign_up_params[:caller_id_number], organization_id: current_user.organization.id)
	  	end
	  	# Ensures users don't try to create users with caller_id_numbers that are not associated with their organization
	  	if existing_numbers.nil?
	  		flash[:alert] = "Permission denied."
	  		redirect_to(root_path)
	  	end
	  end
end
