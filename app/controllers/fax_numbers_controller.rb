class FaxNumbersController < ApplicationController
	include SessionsHelper
	before_action :verify_is_admin

	def index
		@fax_numbers = FaxNumber.combine_api_numbers_with_db_numbers(FaxNumber.all)
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

	private
		def verify_is_admin
			if !is_admin?
				flash[:alert] = "Permission denied."
				redirect_to root_path
			end
		end

		def fax_number_params
			params.require(:fax_number).permit(:fax_number, :fax_number_label, :id)
		end

end