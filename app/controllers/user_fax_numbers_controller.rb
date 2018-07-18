class UserFaxNumbersController < ApplicationController
	include SessionsHelper

	before_action :set_fax_number, only: [:edit, :update]
	before_action :verify_authorized, only: [:edit, :update]

	def edit
		@fax_number.unassigned_organization_users = FaxNumber.get_unassigned_organization_users(@fax_number) if @fax_number.organization
	end

	def update
		unless params[:users].nil?
			add_user_associations(user_association_params[:to_add], @fax_number) if params[:users][:to_add]
			remove_user_associations(user_association_params[:to_remove], @fax_number) if params[:users][:to_remove]
		end

		flash[:notice] = "Changes successfully saved."
		redirect_to(organization_path(@fax_number.organization.id))
	end

	private 
		def set_fax_number
			@fax_number ||= FaxNumber.find(params[:id])
		end

		def user_association_params
			params.require(:users).permit(:to_add => {}, :to_remove => {})
		end

		def add_user_associations(param_input, fax_number_object) # equivalent of @fax_number << UserEmail
			param_input.keys.each { |user_object_id| fax_number_object.users << User.find(user_object_id.to_i) }
		end

		def remove_user_associations(param_input, fax_number_object)
			param_input.keys.each { |user_object_id| UserFaxNumber.where( { user_id: user_object_id } ).destroy_all }
		end

		def verify_authorized
			if !authorized?(@fax_number.organization, :manager_id)
				flash[:alert] = DENIED
				redirect_to root_path
			end
		end
end