class MailgunFaxesController < ApplicationController
	skip_before_action :verify_authenticity_token, only: [:fax_received, :fax_sent, :mailgun]

	# POST /fax_received: email sent out to the user_emails associated w/a fax number that received a fax
	def fax_received
		puts "FAX_RECEIVED MAILGUN CONTROLLER METHOD"
		p "==============================================================================="
		p params
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
		p "==============================================================================="
		p params
		@sender = UserEmail.find_by(params["fax"]["tags"]["sender_fax_tag"])
		@client = Client.find_by(params["fax"]["tags"]["sender_client_fax_tag"])
		PhaxMachineMailer.fax_sent_email(@sender, @client).deliver_now
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

	private
		def mailgun_params
			params.require(:fax).permit(:id, :num_pages, :cost, :direction, :status, :is_test, :requested_at, :completed_at, { recipients: {} }, )
		end
end

{"fax"=>"{\"id\":76230670,\"num_pages\":1,\"cost\":7,\"direction\":\"sent\",\"status\":\"success\",\"is_test\":true,\"requested_at\":1530027390,\"completed_at\":1530027393,\"recipients\":[{\"number\":\"+12096904545\",\"status\":\"success\",\"bitrate\":\"14400\",\"resolution\":\"7700\",\"completed_at\":1530027393}],\"tags\":{\"sender_client_fax_tag\":\"6c4ae3b9-ddf9-445f-809c-6add4eaf48e5\",\"sender_fax_tag\":\"ef0e09a0-d02f-46b9-99d0-9afeebb565e1\"}}", "direction"=>"sent", "is_test"=>"true", "success"=>"true", "controller"=>"mailgun_faxes", "action"=>"fax_sent"}
