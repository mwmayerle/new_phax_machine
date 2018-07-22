class MailgunFaxesController < ApplicationController
	skip_before_action :verify_authenticity_token
	before_action :verify_phaxio_callback, only: [:fax_received]

	DIGEST = OpenSSL::Digest.new('sha1')
  private_constant :DIGEST

	def fax_received
		@fax = strong_phaxio_params
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
		@fax = strong_phaxio_params
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
			Fax.set_phaxio_creds
	    signature = request.env['HTTP_X_PHAXIO_SIGNATURE']
	    file_params = params['file']
	    p "*****************************************************************************"
	    url = request.url
	    phaxio_params = strong_phaxio_params.to_h
	    if valid_signature?(signature, url, phaxio_params, file_params)
	    	puts "IT WORKED!!!!!!!!!!!!!!!"
	    	render(status: 200)
	    else
	    	puts "IT BROKE!!!!!!!!!!!!!!!!!"
	    	render(status: 422)
	    end
	  end

	  def callback_params
	    phaxio_params.select do |key, _value|
	      %w(success is_test direction fax metadata message).include?(key)
	    end
	  end

	  def strong_phaxio_params
	  	# Create new params from the existing params and then filter them due to the JSON component returned from the Phaxio API
	  	new_params = ActionController::Parameters.new({:fax => JSON.parse(params[:fax])})
	  	new_params.require(:fax).permit(	  		
	  		:id,
	  		:direction,
	  		:num_pages,
	  		:status,
	  		:is_test,
	  		:caller_id,
	  		:caller_name,
	  		:from_number,
	  		:caller_name,
	  		:cost,
	  		:to_number,
	  		:error_id,
	  		:error_type,
	  		:error_message,
	  		:file,
	  		{ :barcodes => [] },
	  		{ :tags => [
	  			:sender_organization_fax_tag,
	  			:sender_email_fax_tag]
	  		},
	  		{ :recipients => [
	  				:phone_number,
	  				:status,
	  				:error_type,
	  				:error_id,
	  				:error_message,
	  				:to_number
	  			]
	  		},
	  	)
	  end

	  ####################################################

	  def valid_signature? signature, url, params, files = []
      check_signature = generate_check_signature url, params, files
      check_signature == signature
    end

	  def generate_check_signature url, params, files = []
      params_string = generate_params_string(params)
      files_string = generate_files_string(files)
      callback_data = "#{url}#{params_string}#{files_string}"
      OpenSSL::HMAC.hexdigest(DIGEST, callback_token, callback_data)
    end

    def callback_token
      Phaxio.callback_token or raise(Phaxio::Error::PhaxioError, 'No callback token has been set')
    end

    def generate_params_string(params)
      sorted_params = params.keys.sort_by { |key, _value| key }
      params_strings = sorted_params.map { |key, value| "#{key}#{value}" }
      params_strings.join
    end

    def generate_files_string(files)
      files_array = files_to_array(files).reject(&:nil?)
      p "11111111111111111111111111111111"
      p files_array
      p "22222222222222222222222222222222"
      ##############
      sorted_files = files_array.sort_by { |file| file.name }
      ##############
      p sorted_files
      files_strings = sorted_files.map { |file| generate_file_string(file) }
      files_strings.join
    end

    def files_to_array(files)
      files.is_a?(Array) ? files : [files]
    end

    def generate_file_string(file)
      file.name + DIGEST.hexdigest(file.tempfile.read)
    end
end