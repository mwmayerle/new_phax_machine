class MailgunFaxesController < ApplicationController

	# POST /fax_received: email sent out to the user_emails associated w/a fax number that received a fax
	def fax_received
		puts "FAX_RECEIVED MAILGUN CONTROLLER METHOD"
		PhaxMachineMailer.fax_received_email.deliver_now
		# fax = JSON.parse params['fax']
  #   recipient_number = Phonelib.parse(@fax['to_number']).e164
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
	end

	# POST /fax_sent: email sent out to the user_emails associated w/a fax number that sent a fax
	def fax_sent
		puts "FAX_SENT MAILGUN CONTROLLER METHOD"
		PhaxMachineMailer.fax_sent_email.deliver_now
		# @fax = JSON.parse params['fax']
  #   fax_tag = @fax['tags']['user']
  #   begin
  #     user_id = db[:users].where(fax_tag: fax_tag).first[:id]
  #     email_addresses = db[:user_emails].where(user_id: user_id).all.map { |user_email| user_email[:email] }
  #   ensure
  #     db.disconnect
  #   end

  #   if @fax["status"] == "success"
  #   	email_subject = "Your fax was sent successfully"
  #   else
  #   	@fax["most_common_error"] = most_common_error(@fax)
  #   	email_subject = "Your fax failed because: #{@fax["most_common_error"]}"
  #   end

  #   Pony.mail(
  #     to: email_addresses,
  #     from: smtp_from_address,
  #     subject: email_subject,
  #     html_body: erb(:fax_email, layout: false),
  #     via: :smtp,
  #     via_options: smtp_options
  #   )
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
end
