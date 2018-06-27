class MailgunFaxesController < ApplicationController
	skip_before_action :verify_authenticity_token, only: [:fax_received, :fax_sent, :mailgun]
	# POST /fax_received: email sent out to the user_emails associated w/a fax number that received a fax
	def fax_received
		puts "FAX_RECEIVED MAILGUN CONTROLLER METHOD"
		@fax = JSON.parse(params['fax'])
    p recipient_number = Phonelib.parse(@fax['to_number']).e164
    p fax_number = FaxNumber.find_by(fax_number: recipient_number)

    # if these are blank, then no fax_recieved email is sent
    "======================================================="
    fax_num_user_email_objs = FaxNumberUserEmail.where(fax_number_id: fax_number.id)
    email_addresses = fax_num_user_email_objs.map { |fax_num_email_obj| fax_num_email_obj.user_email.email_address }
    "======================================================="

    fax_from = @fax['from_number']
    fax_file_name = params['filename'].original_filename
    fax_file_contents = params['filename'].read
    p attachments = { fax_file_name => fax_file_contents }

    email_subject = "Fax received from #{fax_from}"
		MailgunMailer.fax_email(email_addresses, email_subject, @fax, attachments).deliver_now
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
			# params.require('fax').permit('filename', 'id', 'num_pages', 'cost', 'direction', 'status', 'is_test', 'requested_at', 'completed_at', { 'recipients':
			# 	['number', 'status', 'bitrate', 'resolution', 'completed_at']}, { 'tags': ['sender_client_fax_tag', 'sender_fax_tag'] })
			params.require('fax').permit!({'filename': {} }, 'id', 'num_pages', 'cost', 'direction', 'status', 'is_test', 'requested_at', 'completed_at', { 'recipients':
				['number', 'status', 'bitrate', 'resolution', 'completed_at']}, { 'tags': ['sender_client_fax_tag', 'sender_fax_tag'] })
		end
end
