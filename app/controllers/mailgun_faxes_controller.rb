class MailgunFaxesController < ApplicationController
	skip_before_action :verify_authenticity_token, only: [:fax_received, :fax_sent, :mailgun]

	def fax_received
		@fax = JSON.parse(params['fax'])
    recipient_number = Phonelib.parse(@fax['to_number']).e164
    fax_number = FaxNumber.find_by(fax_number: recipient_number)

    email_addresses = FaxNumberUserEmail.where(fax_number_id: fax_number.id).all.map do |fax_num_email_obj|
    	fax_num_email_obj.user_email.email_address
    end

    fax_from = @fax['from_number']
    fax_file_name = params['filename'].original_filename
    fax_file_contents = params['filename'].read
    email_subject = "Fax received from #{fax_from}"

		MailgunMailer.fax_email(email_addresses, email_subject, @fax, fax_file_name, fax_file_contents).deliver_now
	end

	def fax_sent
		@fax = JSON.parse(params['fax'])
		p @fax
		email_addresses = UserEmail.find_by(fax_tag: @fax['tags']['sender_email_fax_tag']).email_address

    if @fax["status"] == "success"
    	email_subject = "Your fax was sent successfully"
    else
    	@fax["most_common_error"] = Fax.most_common_error(@fax)
    	email_subject = "Your fax failed because: #{@fax["most_common_error"]}"
    end

		MailgunMailer.fax_email(email_addresses, email_subject, @fax).deliver_now
	end

	def mailgun(files = [])
    return [400, "Must include a sender"] if !params['from']					# Make this send a fail email
    return [400, "Must include a recipient"] if !params['recipient']	# Make this send a fail email

    attachment_count = params['attachment-count'].to_i

    i = 1
    while i <= attachment_count do
      output_file = "/tmp/#{Time.now.to_i}-#{rand(200)}-" + params["attachment-#{i}"].original_filename
      file_data = File.binread(params["attachment-#{i}"].tempfile.path)
      IO.binwrite(output_file, file_data)
      files.push(output_file)
      i += 1
    end

    sender = Mail::AddressList.new(params['from']).addresses.first.address
 		sent_fax_object = Fax.create_fax_from_email(sender, params['recipient'], files)
 		api_response = Fax.get_fax_information(sent_fax_object)
 		
 		if api_response.status != 'queued'
	 		MailgunMailer.email_to_fax_failed(sender, files, api_response.recipients).deliver_now
	 	end
	end
end