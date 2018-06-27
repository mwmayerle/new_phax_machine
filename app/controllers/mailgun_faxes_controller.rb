class MailgunFaxesController < ApplicationController
	skip_before_action :verify_authenticity_token, only: [:fax_received, :fax_sent, :mailgun]

	# POST /fax_received: email sent out to the user_emails associated w/a fax number that received a fax
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

	# POST /fax_sent: email sent out to the user_emails associated w/a fax number that sent a fax
	def fax_sent
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
		p "==================="
    return [400, "Must include a sender"] if not params['from']
    return [400, "Must include a recipient"] if not params['recipient']

    files = []
    attachment_count = params['attachment-count'].to_i

    i = 1
    while i <= attachment_count do
      #add the file to the hash
      p output_file = "/tmp/#{Time.now.to_i}-#{rand(200)}-" + params["attachment-#{i}"].original_filename

      # file_data = File.binread(params["attachment-#{i}"][:tempfile].path)
      # IO.binwrite(outputFile, file_data)

      # files.push(outputFile)

      i += 1
     end

    # sender = Mail::AddressList.new(params['from']).addresses.first.address
    # sendFax(sender, params['recipient'],files)
	end
end

# <ActionController::Parameters {"Content-Type"=>"multipart/mixed; boundary=\"0000000000008cf141056fa6530f\"",
# "Date"=>"Wed, 27 Jun 2018 16:30:39 -0500",
# "From"=>"Matt Mayerle <matt@phaxio.com>", 
# "To"=>"12096904545@sandbox977f2cd8bec345c1b453b2f03b0f447c.mailgun.org", 
# "X-Envelope-From"=>"<matt@phaxio.com>", 
# "attachment-count"=>"1", 
# "body-html"=>"<div dir=\"ltr\"><br></div>\r\n", "body-plain"=>"\r\n",
# "from"=>"Matt Mayerle <matt@phaxio.com>",
# "recipient"=>"12096904545@sandbox977f2cd8bec345c1b453b2f03b0f447c.mailgun.org",
# "sender"=>"matt@phaxio.com",
# "signature"=>"456c4079cc56e1fb206cdf34eed07daed18fe6657e2a8c49aed2d41f6ce804b7",
# "stripped-html"=>"<div dir=\"ltr\"><br></div>\n",
# "stripped-signature"=>"",
# "stripped-text"=>"",
# "subject"=>"",
# "timestamp"=>"1530135042",
# "token"=>"3311eddaaa0d2940391df59704bb5f332d5138cfe2bf5f13b7",
# "attachment-1"=><ActionDispatch::Http::UploadedFile:0x0000000005dd06d0 @tempfile=#<Tempfile:/tmp/RackMultipart20180627-4-kn3upl.odt>, @original_filename="testytest.odt", @content_type="application/vnd.oasis.opendocument.text", @headers="Content-Disposition: form-data; name=\"attachment-1\"; filename=\"testytest.odt\"\r\nContent-Type: application/vnd.oasis.opendocument.text\r\nContent-Length: 8573\r\n">, "controller"=>"mailgun_faxes", "action"=>"mailgun"} permitted: false>
