class ClientsController < ApplicationController
	include SessionsHelper

	before_action :verify_is_admin, only: [:index, :new, :create, :edit, :update, :destroy]
	before_action :set_client, only: [:show, :edit, :update, :destroy, :add_emails]
	before_action :get_unallocated_numbers, only: [:index, :new, :edit]

	def index
		@clients = Client.all
	end

	def new
		@client = Client.new
	end

	def create
		@client = Client.new(client_params)
		if @client.save
			unless params[:fax_numbers].nil?
				add_fax_number_associations(client_association_params[:to_add], @client.id) if params[:fax_numbers][:to_add]
			end
			flash[:notice] = "Client created successfully."
			redirect_to clients_path
		else
			flash[:alert] = @client.errors.full_messages.pop
			render :new
		end
	end

	def show
		if authorized?(@client, :client_manager_id)
			@unused_emails = @client.user_emails.select { |client_email| client_email.fax_number_user_emails.empty? } # == [] possible bug
			render :show
		else
			flash[:alert] = "Permission denied."
			redirect_to root_path
		end
	end

	def edit
	end

	def update
		if @client.update_attributes(client_params)
			unless params[:fax_numbers].nil?
				add_fax_number_associations(client_association_params[:to_add], @client.id) if params[:fax_numbers][:to_add]
				remove_fax_number_associations(client_association_params[:to_remove]) if params[:fax_numbers][:to_remove]
			end
			flash[:notice] = "Client updated successfully."
			redirect_to clients_path
		else
			flash[:alert] = @client.errors.full_messages.pop
			render :edit
		end
	end

	def destroy
		remove_fax_number_associations(@client.fax_numbers.map { |fax_number| fax_number.id })
		@client.destroy
		flash[:notice] = "Client deleted successfully."
		redirect_to clients_path
	end

	private

		def set_client
			@client ||= Client.find(params[:id])
		end

		def get_unallocated_numbers
			@unallocated_fax_numbers = FaxNumber.where(client_id: nil)
		end

		def client_params
			params.require(:client).permit(:id, :client_manager_id, :client_label, :admin_id)
		end

		def client_association_params
			params.require(:fax_numbers).permit(:to_add => {}, :to_remove => {})
		end

		def add_fax_number_associations(param_input, client_id)
			param_input.each { |fax_number_id, fax_number| FaxNumber.find(fax_number_id.to_i).update(client_id: client_id) }
		end

		def remove_fax_number_associations(param_input)
			param_input.each do |fax_number_id, fax_number| 
				fax_number = FaxNumber.find(fax_number_id.to_i)
				fax_number.update_attributes({client_id: nil, fax_number_display_label: "Unlabeled"})
				fax_num_user_email = FaxNumberUserEmail.where(fax_number_id: fax_number.id).destroy_all
			end
		end
end