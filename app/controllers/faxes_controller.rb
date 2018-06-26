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
		sent_fax_object = Phaxio::Fax.create(
			to: fax_params[:to],
			file: attached_files,
			tag: {
				sender_client_fax_tag: current_user.client.fax_tag,
				sender_fax_tag: current_user.user_email.fax_tag,
			},
		)
		api_response = Phaxio::Fax.get(sent_fax_object.get.id)
		flash_message_type = api_response.status == "queued" ? :notice : :alert
		puts "Output for sending fax via in-app form"
		p api_response
		flash[flash_message_type] = api_response.status
		redirect_to new_fax_path
	end

	def show
	end

	# GET /download_file
	def download_file
		# fax_id = params["fax_id"].to_i
  #   api_response = Phaxio.get_fax_file(id: fax_id, type: "p")
  #   download_file(api_response)
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