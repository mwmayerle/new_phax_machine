class MailgunFaxesController < ApplicationController
	skip_before_action :verify_authenticity_token, only: [:fax_received, :fax_sent, :mailgun]

	# POST /fax_received: email sent out to the user_emails associated w/a fax number that received a fax
	def fax_received
		puts "FAX_RECEIVED MAILGUN CONTROLLER METHOD"
		p "==============================================================================="
		@fax = JSON.parse(params['fax'])
		p "======"
		p "@fax"
		p @fax
		p "======"
		p "recipient_number"
    recipient_number = Phonelib.parse(@fax['to_number']).e164
    p recipient_number
    p "======"
    p "fax_number object"
    fax_number = FaxNumber.find_by(fax_number: recipient_number)
    p fax_number
    p "======"
    p "fax_num_user_emails obj"
    emails = FaxNumberUserEmail.where(fax_number_id: fax_number.id)
    p emails
    p "======"
    p "email objects"
    emails.each { |lol| p lol.user_email.email_address}
  #   begin
  #     user_id = db[:users].where(fax_number: recipient_number).first[:id]
  #     email_addresses = db[:user_emails].where(user_id: user_id).all.map { |user_email| user_email[:email] }
  #   ensure
  #     db.disconnect
  #   end

  #   fax_from = @fax['from_number']
  #   fax_file_name = params['filename']['filename']
  #   fax_file_contents = params['filename']['tempfile'].read
  #   email_subject = "Fax received from #{fax_from}"

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
		# MailgunMailer.fax_email(@sender, @client).deliver_now
	end

	# POST /fax_sent: email sent out to the user_emails associated w/a fax number that sent a fax
	def fax_sent
		puts "FAX_SENT MAILGUN CONTROLLER METHOD"
		@fax = JSON.parse(params['fax'])
		fax_sender = UserEmail.find_by(fax_tag: @fax['tags']['sender_email_fax_tag'])

    if @fax["status"] == "success"
    	email_subject = "Your fax was sent successfully"
    else
    	@fax["most_common_error"] = Fax.most_common_error(@fax)
    	email_subject = "Your fax failed because: #{@fax["most_common_error"]}"
    end
		MailgunMailer.fax_email(fax_sender, email_subject, @fax).deliver_now
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
				['number', 'status', 'bitrate', 'resolution', 'completed_at']}, { 'tags': ['sender_client_fax_tag', 'sender_fax_tag'] })
		end
end
