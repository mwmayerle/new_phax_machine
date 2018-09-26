class FaxesController < ApplicationController
	include SessionsHelper
	
	before_action :verify_user_signed_in
	before_action :set_phaxio_creds

	def new
		redirect_to(fax_numbers_path) if is_admin?
	end

	# POST for sending a fax via the internal view
	def create(attached_files = [])
		fax_params[:files].each { |file_in_params| attached_files << file_in_params[1].tempfile } # No .map() for ActionCont. params
		options = {
			to: fax_params[:to],
			files: attached_files,
			caller_id: current_user.caller_id_number,
			tag: {
				sender_organization_fax_tag: current_user.organization.fax_tag, 
				sender_email_fax_tag: current_user.fax_tag,
			},
		}
		sent_fax_response = Fax.create_fax(options)
		if sent_fax_response.is_a?(Phaxio::Error::PhaxioError)
			flash[:alert] = "Error: ".concat(sent_fax_response.to_s)
		else
			api_response = Fax.get_fax_information(sent_fax_response)
			api_response.status == 'queued' ? flash[:notice] = 'Fax queued for sending' : flash[:alert] = api_respons.eerror_message
		end
		redirect_to new_fax_path
	end

	def download
		api_response = Fax.download_file(params[:fax_id])
		if !api_response.is_a?(String)
   		send_file(api_response.path, filename: "Fax-#{params[:fax_id]}.pdf", type: :pdf, disposition: "attachment")
   	end
	end

	private
		def fax_params
			params.require(:fax).permit(:id, :fax_id, :to, { files: [:file1, :file2, :file3, :file4, :file5, :file6, :file7, :file8, :file9, :file10] })
		end

		def verify_user_signed_in
			redirect_to new_user_session_path if !user_signed_in?
		end

		def set_phaxio_creds
			Fax.set_phaxio_creds
		end
end