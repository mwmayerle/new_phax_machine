# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
	include SessionsHelper
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  	before_action :verify_permissions, only: [:create, :destroy]
  	prepend_before_action :require_no_authentication, only: :cancel

  # POST /resource
  def create
  	if sign_up_params[:invite].nil?
    	new_email = UserEmail.create!(
    		email_address: sign_up_params[:email],
    		caller_id_number: sign_up_params[:caller_id_number], # make a UserEmail but no User
    		client_id: sign_up_params[:client_id]
    	)
    	new_email ? flash[:notice] = "User successfully created." : flash[:alert] = @user_email.errors.full_messages.pop
    # There is an "invite" attr_accessor in User model that determines whether a UserEmail, or both a User and
    # a UserEmail object are created simultaneously. 'if sign_up_params[:invite]' above is addressing this.
    else 
	    build_resource(sign_up_params)
	    resource.save
	    yield resource if block_given?
	    if resource.persisted?
		    user = User.find(resource.id)   

	    	if resource.type == User::CLIENT_MANAGER
		    	client = Client.find(resource.client_id)
		    	client.update_attributes(client_manager_id: user.id)
		    	existing_email = UserEmail.find_by(email_address: user.email)

		    	if existing_email.nil?
			    	new_email = UserEmail.create!(                            # 
			    		email_address: user.email,                              # Creating a ClientManager user from
			    		client_id: client.id,                                   # scratch w/no previously persisted
			    		user_id: user.id,                                       # UserEmail object
			    		caller_id_number: client.fax_numbers.first.fax_number   #
			    	)
			    	new_email ? flash[:notice] = "User successfully created." : flash[:alert] = @user_email.errors.full_messages.pop
			    else																											#
			    	existing_email.update_attributes(user_id: user.id.to_i) # Creating ClientManager with an existing UserEmail object
			    end 																											#

			  elsif resource.type == User::USER
			  	existing_email = UserEmail.find_by(email_address: user.email)
			  	if existing_email.nil?
			    	new_email = UserEmail.create!(
			    		caller_id_number: sign_up_params[:caller_id_number],
			    		client_id: user.client.id,
			    		email_address: user.email,               
			    		user_id: user.id,
			    	)
			    	new_email ? flash[:notice] = "User successfully created." : flash[:alert] = @user_email.errors.full_messages.pop
			    else																											#
			    	existing_email.update_attributes(user_id: user.id.to_i) # Creating generic User with an existing UserEmail object
			    end 																											# 																				
		    else
		    	UserEmail.find_by(email_address: user.email).update(user_id: user.id) # Creating a User from existing UserEmail
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
    	resource.type == User::USER ? redirect_to(client_path(resource.client)) : redirect_to(clients_path)
    else
    	redirect_to(client_path(sign_up_params[:client_id]))
    end
  end

  # DELETE /resource
  def destroy
  	resource = User.find(params[:id])
  	UserEmail.find_by(user_id: resource.id).update_attributes(user_id: nil) # retains the UserEmail obj

		client = current_user.client.nil? ? Client.find(resource.client.id) : current_user.client
		client.update_attributes(client_manager_id: nil) if resource.type == User::CLIENT_MANAGER # Removes client_manager privileges

    resource.destroy
    flash[:notice] = "Access for #{resource.email} revoked"
    yield resource if block_given?
    redirect_to(client_path(client))
  end

  protected

	# 'is_client_manager?' returns true if the user is a ClientManager or Admin, so if they're not an 
	# admin and a ClientManager user is trying to be created OR they're not an Admin or ClientManager 
	# and a generic user is being created, then redirect
	  def verify_permissions
	  	if !is_admin? && sign_up_params[:type] == User::CLIENT_MANAGER || !is_client_manager?
	  		flash[:alert] = "Permission denied."
	  		redirect_to_root_path
	  	end
	  end
end
