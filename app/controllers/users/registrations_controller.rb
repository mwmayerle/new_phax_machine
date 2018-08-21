# frozen_string_literal: true
class Users::RegistrationsController < Devise::RegistrationsController
	include SessionsHelper
  # before_action :configure_sign_up_params, only: [:create]
  	before_action :verify_fax_numbers, only: [:create]
  	before_action :verify_permissions_create, only: [:create]
  	before_action :verify_is_manager_or_admin, only: [:destroy]
  	prepend_before_action :require_no_authentication, only: :cancel

  # POST /resource
  def create
  	# Restores soft-deleted user and associations. See Paranoia gem docs
  	possible_user = User.only_deleted.select { |user| user.email == sign_up_params[:email] }
  	if possible_user != []
  		possible_user = possible_user.pop
  		possible_user.restore(:recursive => true)

  		if possible_user.organization_id != sign_up_params[:organization_id]
  			possible_user.update_attributes(organization_id: sign_up_params[:organization_id])
  		end

  		if possible_user.caller_id_number != sign_up_params[:caller_id_number]
  			possible_user.update_attributes(caller_id_number: sign_up_params[:caller_id_number])
  		end

  		# If restored user is being invited as a manager and sets the Org's manager_id
  		UserPermission.find_by(user_id: possible_user.id).update_attributes(permission: sign_up_params[:permission])

  		if sign_up_params[:permission] == UserPermission::MANAGER
  			Organization.find(sign_up_params[:organization_id]).update_attributes(manager_id: possible_user.id)
  		end
  		flash[:notice] = "Access has been reinstated for #{possible_user.email}"

  	else
	    build_resource(sign_up_params)
	    yield resource if block_given?
	    resource.save
	    if resource.persisted?
	    	resource.permission
		    user = User.find(resource.id)
		    UserPermission.create(user_id: user.id, permission: resource.permission)

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
	  end
		if resource
    	resource.permission == UserPermission::USER ? redirect_to(organization_path(resource.organization)) : redirect_to(organizations_path)
    else
    	redirect_to(organization_path(sign_up_params[:organization_id]))
    end
  end

  # PUT /resource
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)
    resource_updated = update_resource(resource, account_update_params)
    yield resource if block_given?
    if resource_updated
      if is_flashing_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ? :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end

      # LINES 81 TO 98 FAIL WHEN NO LOGOLINK OBJECT EXISTS. FIX IT
      # Admin-only site logo
      if is_admin? && account_update_params[:logo_url] != session[:logo_url]
	      logo = LogoLink.first
	  		if logo && logo.update_attributes(logo_url: account_update_params[:logo_url])
		  		flash[:notice] << " Logo successfully updated"
					session[:logo_url] = account_update_params[:logo_url]
				else
					if logo
						flash[:notice] << " However, #{logo.errors.full_messages.pop} Please try again."
					else
						LogoLink.create(logo_url: account_update_params[:logo_url])
					end
			  end
				# Sends user back to edit page if the image update fails
	    	if logo.errors.full_messages.present? #
	    		render(:edit) and return
	    	end
    	end
      bypass_sign_in(resource, scope: resource_name)
      respond_with(resource, location: after_update_path_for(resource))
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  # DELETE /resource
  def destroy
  	resource = User.find(params[:id])
  	organization = Organization.find(resource.organization.id)

		# Removes Manager privileges if admin is revoking their access
		organization.update_attributes(manager_id: nil) if resource.user_permission.permission == UserPermission::MANAGER

    resource.destroy
    flash[:notice] = "Access for #{resource.email} revoked"
    yield resource if block_given?
    is_admin? ? redirect_to(organization_path(id: organization.id)) : redirect_to(organization_path(current_user.organization))
  end

  protected
	  def verify_permissions_create
	  	# Ensures a new admin cannot be created and that a manager can only be created by an admin
	  	if sign_up_params[:permission] == UserPermission::USER
	  		verify_is_manager_or_admin
	  	elsif sign_up_params[:permission] == UserPermission::MANAGER
	  		verify_is_admin
	  	else
	  		flash[:alert] = ApplicationController::DENIED
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
	  		flash[:alert] = ApplicationController::DENIED
	  		redirect_to(root_path)
	  	end
	  end

    def after_update_path_for(resource)
      root_path
    end
end
