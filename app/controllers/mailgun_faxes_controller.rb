class MailgunFaxesController < ApplicationController
	skip_before_action :verify_authenticity_token, only: [:fax_received, :fax_sent, :mailgun]

	# POST /fax_received: email sent out to the user_emails associated w/a fax number that received a fax
	def fax_received
		puts "FAX_RECEIVED MAILGUN CONTROLLER METHOD"
		p "==============================================================================="
		@fax = JSON.parse(params['fax'])
		p @fax
    recipient_number = Phonelib.parse(@fax['to_number']).e164
    fax_number = FaxNumber.find_by(fax_number: recipient_number)
    fax_num_user_email_objs = FaxNumberUserEmail.where(fax_number_id: fax_number.id)
    email_addresses = fax_num_user_email_objs.map { |fax_num_email_obj| fax_num_email_obj.user_email.email_address }

    fax_from = @fax['from_number']
    p fax_file_name = mailgun_params['filename']['filename']
    p fax_file_contents = mailgun_params['filename']['tempfile'].read
    email_subject = "Fax received from #{fax_from}"
    attachments = { fax_file_name => fax_file_contents }
  #   Pony.mail(
  #     to: email_addresses,
  #     from: smtp_from_address,
  #     subject: email_subject,
  #     html_body: erb(:fax_email, layout: false),
  #     attachments: {
  #       fax_file_name => fax_file_contents
  #     },
  #     via: :smtp,
  #     via_options: smtp_options
  #   )
		MailgunMailer.fax_email(email_addresses, email_subject, @fax).deliver_now
	end

	# POST /fax_sent: email sent out to the user_emails associated w/a fax number that sent a fax
	def fax_sent
		puts "FAX_SENT MAILGUN CONTROLLER METHOD"
		@fax = JSON.parse(params['fax'])
		email_addresses = UserEmail.find_by(fax_tag: @fax['tags']['sender_email_fax_tag']).email_address

    if @fax["status"] == "success"
    	email_subject = "Your fax was sent successfully"
    else
    	@fax["most_common_error"] = Fax.most_common_error(@fax)
    	email_subject = "Your fax failed because: #{@fax["most_common_error"]}"
    end
		MailgunMailer.fax_email(email_addresses, email_subject, @fax).deliver_now
	end

	# POST /mailgun
	def mailgun
		# if not params['from']
  #     return [400, "Must include a sender"]
  #   elsif not params['recipient']
  #     return [400, "Must include a recipient"]
  #   end

  #   files = []
  #   attachmentCount = params['attachment-count'].to_i

  #   i = 1
  #   while i <= attachmentCount do
  #     #add the file to the hash
  #     outputFile = "/tmp/#{Time.now.to_i}-#{rand(200)}-" + params["attachment-#{i}"][:filename]

  #     file_data = File.binread(params["attachment-#{i}"][:tempfile].path)
  #     IO.binwrite(outputFile, file_data)

  #     files.push(outputFile)

  #     i += 1
  #     end

  #   sender = Mail::AddressList.new(params['from']).addresses.first.address
  #   sendFax(sender, params['recipient'],files)
  #   "OK"
	end

	private
		def mailgun_params
			params.require('fax').permit('id', 'num_pages', 'cost', 'direction', 'status', 'is_test', 'requested_at', 'completed_at', { 'recipients':
				['number', 'status', 'bitrate', 'resolution', 'completed_at']}, { 'tags': ['sender_client_fax_tag', 'sender_fax_tag'] }, { 'filename': {} })
		end

		{"fax"=>"{\"id\":76429796,\"num_pages\":1,\"cost\":7,\"direction\":\"received\",\"status\":\"success\",\"is_test\":false,\"requested_at\":1530127899,\"completed_at\":1530127897,\"from_number\":\"+18777115706\",\"to_number\":\"+12096904545\"}", "direction"=>"received", "is_test"=>"false", "success"=>"true", "filename"=>#<ActionDispatch::Http::UploadedFile:0x0000000005b071d8 @tempfile=#<Tempfile:/tmp/RackMultipart20180627-4-ke1bij.pdf>, @original_filename="Fax-76429796.pdf", @content_type="application/octet-stream", @headers="Content-Disposition: form-data; name=\"filename\"; filename=\"Fax-76429796.pdf\"\r\nContent-Type: application/octet-stream\r\n">}

end
