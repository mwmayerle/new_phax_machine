class OrganizationsController < ApplicationController
	include SessionsHelper

	before_action :verify_is_admin, except: [:show, :edit_logo, :update_logo]
	before_action :set_organization, only: [:show, :edit, :update, :destroy, :edit_logo, :update_logo]
	before_action :get_unallocated_numbers, only: [:new, :edit]

	def index
		@user = User.new
		@user.build_user_permission
		FaxNumber.format_and_retrieve_fax_numbers_from_api if FaxNumber.first.nil?
		@organizations = Organization.includes(:fax_numbers).order(label: :asc)
	end

	def new
		@organization = Organization.new
	end

	def create
		@organization = Organization.new(organization_params)
		if @organization.save

			unless params[:fax_numbers].nil?
				add_fax_number_associations(organization_association_params[:to_add], @organization.id) if params[:fax_numbers][:to_add]
			end

			flash[:notice] = "Organization created successfully."
			redirect_to organizations_path
			
		else
			flash[:alert] = @organization.errors.full_messages.pop
			render :new
		end
	end

	def show
		@user = User.new
		if authorized?(@organization, :manager_id)
			@unassigned_users = Organization.get_unassigned_users(@organization)
		else
			flash[:alert] = DENIED
			redirect_to root_path
		end
	end

	def edit
	end

	def update_logo
		if is_manager? || current_user.manager == @organization.manager
			if @organization && @organization.update_attributes(logo: logo_params[:logo])
				flash[:notice] = "Logo successfully updated!"
				redirect_to(organization_path(@organization))
			else
				flash[:alert] = @organization.errors.full_messages.pop
				render(:edit_logo)
			end
		else
			flash[:alert] = ApplicationController::DENIED
			redirect_to root_path
		end
	end

	def update
		if @organization.update_attributes(organization_params)

			unless params[:fax_numbers].nil?
				add_fax_number_associations(organization_association_params[:to_add], @organization.id) if params[:fax_numbers][:to_add]
				remove_fax_number_associations(organization_association_params[:to_remove]) if params[:fax_numbers][:to_remove]
			end

			flash[:notice] = "Organization updated successfully."
			redirect_to organization_path(@organization)
		else
			flash[:alert] = @organization.errors.full_messages.pop
			render :edit
		end
	end

	def destroy
		remove_fax_number_associations(@organization.fax_numbers.map { |fax_number| fax_number.id })
		@organization.destroy
		flash[:notice] = "Organization deleted successfully."
		redirect_to organizations_path
	end

	private

		def set_organization
			if is_admin?
				@organization ||= Organization.includes(:fax_numbers).order("fax_numbers.label ASC").find(params[:id])
			else
				@organization ||= Organization.includes(:fax_numbers).order("fax_numbers.manager_label ASC").find(params[:id])
			end
		end

		def get_unallocated_numbers 
			@unallocated_fax_numbers = FaxNumber.where({organization_id: nil, has_webhook_url: false})
		end

		def logo_params
			params.require(:organization).permit(:logo)
		end

		def organization_params
			params.require(:organization).permit(:id, :manager_id, :label, :admin_id, :logo)
		end

		def organization_association_params
			params.require(:fax_numbers).permit(:to_add => {}, :to_remove => {})
		end

		def add_fax_number_associations(param_input, organization_id)
			param_input.each { |fax_number_id, fax_number| FaxNumber.find(fax_number_id.to_i).update(organization_id: organization_id) }
		end

		def remove_fax_number_associations(param_input)
			param_input.each do |fax_number_id, fax_number| 
				fax_number = FaxNumber.find(fax_number_id.to_i)
				fax_number.update_attributes({organization_id: nil, manager_label: nil})
				fax_num_user_email = UserFaxNumber.where(fax_number_id: fax_number.id).destroy_all
			end
		end
end