class FaxNumbersController < ApplicationController
	include SessionsHelper
	before_action :verify_is_admin
	before_action :set_fax_number, only: [:edit, :update, :destroy]

	def index
		fax_numbers_from_db = FaxNumber.all
		fax_numbers_from_api = FaxNumber.get_and_persist_account_numbers
		@fax_numbers = FaxNumber.combine_api_numbers_with_db_numbers(fax_numbers_from_db, fax_numbers_from_api)
	end

	def new
		@fax_number = FaxNumber.new
	end

	def create
		@fax_number = FaxNumber.create(fax_number_params)
		if @fax_number.save
			flash[:notice] = "Fax number successfully saved."
			redirect_to fax_numbers_path
		else
			flash[:alert] = @fax_number.errors.full_messages.pop
			render :new
		end
	end

	def edit
	end

	def update
		if @fax_number.update_attributes(fax_number_params)
			flash[:notice] = "Fax number successfully saved."
			redirect_to fax_numbers_path
		else
			flash[:alert] = @fax_number.errors.full_messages.pop
			render :edit
		end
	end

	def destroy
		if @fax_number.id
			@fax_number.destroy
			flash[:notice] = "Fax number successfully deleted."
			redirect_to fax_numbers_path
		else
			flash[:alert] = "Permission denied."
			redirect_to root_path
		end
	end

	private
		def verify_is_admin
			if !is_admin?
				flash[:alert] = "Permission denied."
				redirect_to root_path
			end
		end

		def set_fax_number
			@fax_number ||= FaxNumber.find(fax_number_params[:id])
		end

		def fax_number_params
			params.require(:fax_number).permit(:fax_number, :fax_number_label, :id)
		end
end