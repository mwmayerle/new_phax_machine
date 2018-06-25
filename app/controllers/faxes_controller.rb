class FaxesController < ApplicationController

	before_action :set_phaxio_creds

	# GET /logs.json
	def get_logs
	end

	def new
	end

	# POST for sending a fax via the internal view
	def create(attached_files = [])
		# TODO 
		fax_params[:files].each { |file_in_params| attached_files << file_in_params[1].tempfile } # No .map() for ActionController params...
		api_response = Phaxio::Fax.create(
			to: fax_params[:to],
			tag: { sender_fax_tag: current_user.fax_tag, sender_client_fax_tag: current_user.client.fax_tag },
			file: attached_files,
		)
		p api_response
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
			params.require(:fax).permit(:to, { files: [:file1, :file2, :file3, :file4, :file5, :file6, :file7, :file8, :file9, :file10] })
		end

		def set_phaxio_creds
			Fax.set_phaxio_creds
		end
end