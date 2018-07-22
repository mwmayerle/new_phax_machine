class MailgunFaxesController < ApplicationController
	skip_before_action :verify_authenticity_token
	before_action :verify_phaxio_callback, except: [:mailgun]

	def fax_received
		@fax = JSON.parse(params['fax'])
    recipient_number = Phonelib.parse(@fax['to_number']).e164
    fax_number = FaxNumber.find_by(fax_number: recipient_number)

    email_addresses = UserFaxNumber.where(fax_number_id: fax_number.id).all.map do |fax_num_email_obj|
    	fax_num_email_obj.user.email
    end

    fax_from = @fax['from_number']
  	fax_file_name = params['file'].original_filename
    fax_file_contents = params['file'].read

    email_subject = "Fax received from #{fax_from}"

		MailgunMailer.fax_email(email_addresses, email_subject, @fax, fax_file_name, fax_file_contents).deliver_now
	end

	def fax_sent
		@fax = JSON.parse(params['fax'])
		email_addresses = User.find_by(fax_tag: @fax['tags']['sender_email_fax_tag']).email

    if @fax["status"] == "success"
    	email_subject = "Your fax was sent successfully"
    else
    	@fax["most_common_error"] = Fax.most_common_error(@fax)
    	email_subject = "Your fax failed because: #{@fax["most_common_error"]}"
    end

		MailgunMailer.fax_email(email_addresses, email_subject, @fax).deliver_now
	end

	def mailgun(files = [])
    sender = Mail::AddressList.new(params['from']).addresses.first.address
    user = User.find_by(email: sender)

    # Currently fails if user is not in the DB
    attachment_count = params['attachment-count'].to_i

    i = 1
    while i <= attachment_count do
      output_file = "/tmp/#{Time.now.to_i}-#{rand(200)}-" + params["attachment-#{i}"].original_filename
      file_data = File.binread(params["attachment-#{i}"].tempfile.path)
      IO.binwrite(output_file, file_data)
      files.push(output_file)
      i += 1
    end

 		sent_fax_object = Fax.create_fax_from_email(sender, params['recipient'], files, user)
 		if sent_fax_object.class != String
			api_response = Fax.get_fax_information(sent_fax_object)
		else
			MailgunMailer.failed_email_to_fax_email(sender, sent_fax_object).deliver_now
		end
	end

	private
		def verify_phaxio_callback
			p params
			Fax.set_phaxio_creds
	    signature = request.env['HTTP_X_PHAXIO_SIGNATURE']
	    url = request.url
	    phaxio_params = strong_params
	    file_params = params['file']
	    if Phaxio::Callback.valid_signature?(signature, url, phaxio_params.to_h, file_params)
	    	p "=========================================================================================="
	      	puts 'Success'
	      p "=========================================================================================="
	    else
	    	p "=========================================================================================="
	      	puts 'Invalid callback signature'
	      p "=========================================================================================="
	    end
	  end

	  def callback_params
	    phaxio_params.select do |key, _value|
	      %w(success is_test direction fax metadata message).include?(key)
	    end
	  end

	  def strong_params
	  	params.require(:fax).permit(
	  		:id,
	  		:direction,
	  		:num_pages,
	  		:status,
	  		:is_test,
	  		:caller_id,
	  		:from_number,
	  		:caller_name,
	  		:cost,
	  		{ :tags => {} },
	  		{ :recipients => {} },
	  	)
	  end
end