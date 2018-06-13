class ClientsController < ApplicationController
	include SessionsHelper
	
	before_action :verify_is_admin, only: [:index, :new, :create, :edit, :update, :destroy]
	before_action :set_client, only: [:show, :edit, :update, :destroy, :add_emails]

	def index
		@clients = Client.all
		@unallocated_fax_numbers = FaxNumber.where(client_id: nil)
	end

	def new
		@unallocated_fax_numbers = FaxNumber.where(client_id: nil)
		@client = Client.new
	end

	def create
		@client = Client.new(client_params)
		if @client.save
			unless params[:fax_numbers].nil?
				alter_fax_number_associations(client_association_params[:to_add], @client.id) if params[:fax_numbers][:to_add]
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
			render :show
		else
			flash[:alert] = "Permission denied."
			redirect_to root_path
		end
	end

	def edit
		@fax_numbers = FaxNumber.where(client_id: nil)
	end

	def update
		if @client.update_attributes(client_params)
			unless params[:fax_numbers].nil?
				alter_fax_number_associations(client_association_params[:to_add], @client.id) if params[:fax_numbers][:to_add]
				alter_fax_number_associations(client_association_params[:to_remove]) if params[:fax_numbers][:to_remove]
			end
			flash[:notice] = "Client updated successfully."
			redirect_to clients_path
		else
			flash[:alert] = @client.errors.full_messages.pop
			render :edit
		end
	end

	def destroy
		alter_fax_number_associations(@client.fax_numbers.map { |fax_number| fax_number.id })
		@client.destroy
		flash[:notice] = "Client deleted successfully."
		redirect_to clients_path
	end

	private

		def set_client
			@client ||= Client.find(params[:id])
		end

		def client_params
			params.require(:client).permit(:id, :client_manager_id, :client_label, :admin_id)
		end

		def client_association_params
			params.require(:fax_numbers).permit(:to_add => {}, :to_remove => {})
		end

		def alter_fax_number_associations(param_input, value = nil) #nil is for un-associating the FaxNumber, ex: client_id = nil
			param_input.each { |fax_number_id, fax_number| FaxNumber.find(fax_number_id.to_i).update(client_id: value) }
		end
end