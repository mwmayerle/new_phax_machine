class FaxesController < ApplicationController

	before_action :verify_user_signed_in
	before_action :set_phaxio_creds

	# GET /logs.json
	def get_logs
	end

	def new
	end

	# POST for sending a fax via the internal view
	def create(attached_files = [])
		fax_params[:files].each { |file_in_params| attached_files << file_in_params[1].tempfile } # No .map() for ActionCont. params
		sent_fax_object = Fax.create_fax(
			to: fax_params[:to],
			file: attached_files,
			caller_id: current_user.user_email.caller_id_number,
			tag: {
				sender_client_fax_tag: current_user.client.fax_tag,
				sender_email_fax_tag: current_user.user_email.fax_tag,
			},
		)
		api_response = Fax.get_fax_information(sent_fax_object)
		flash_message_type = api_response.status == "queued" ? :notice : :alert
		flash[flash_message_type] = api_response.status
		redirect_to new_fax_path
	end

	def show
	end

	# GET /download_file
	def download_file
	end

	def destroy
	end

	private
		def fax_params
			params.require(:fax).permit(:id, :to, { files: [:file1, :file2, :file3, :file4, :file5, :file6, :file7, :file8, :file9, :file10] })
		end

		def verify_user_signed_in
			if !user_signed_in?
				flash[:alert] = "You must be logged in to send a fax"
				redirect_to root_path
			end
		end

		def set_phaxio_creds
			Fax.set_phaxio_creds
		end
end