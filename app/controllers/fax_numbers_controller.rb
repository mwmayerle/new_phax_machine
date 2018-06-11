class FaxNumbersController < ApplicationController
	include SessionsHelper
	
	before_action :verify_is_admin
	before_action :set_fax_number, only: [:edit, :update, :destroy]

	def index
		@fax_numbers = FaxNumber.format_and_retrieve_fax_numbers_from_api
	end

	def edit
	end

	def update
		if @fax_number.update_attributes(fax_number_params)
			flash[:notice] = "Changes successfully saved."
			redirect_to fax_numbers_path
		else
			flash[:alert] = @fax_number.errors.full_messages.pop
			render :edit
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