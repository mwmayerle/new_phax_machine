class Fax
	class << self
		def get_fax_information(sent_fax_object)
			Phaxio::Fax.get(sent_fax_object.id)
		end

		def create_fax(options)
			sent_fax_object = Phaxio::Fax.create(
				to: options[:to],
				file: options[:files],
				caller_id: options[:caller_id_number],
				tag: {
				  sender_client_fax_tag: options[:sender_client_fax_tag], 
				  sender_email_fax_tag: options[:sender_email_fax_tag]
				},
			)
     	get_fax_information(sent_fax_object)
		end

		def create_fax_from_email(sender, recipient, files)
      number = Mail::Address.new(recipient).local
      user_email = UserEmail.find_by(email_address: sender)

      options = {
      	to: number,
      	caller_id: user_email.caller_id_number,
      	sender_client_fax_tag: user_email.client.fax_tag,
      	sender_email_fax_tag: user_email.fax_tag,
      	files: files.map { |file| File.new(file) }
      }
      create_fax(options)
    end

		# if there are two error_codes with the same frequency, the error found first (first recipient) takes precedence
		def most_common_error(fax, errors = {})
			fax["recipients"].each do |recipient|
		  	key = recipient["error_code"]
		  	errors.has_key?(key) ? errors[key]["frequency"] += 1 : errors[key] = {"frequency" => 1}
			end
	  	errors.max_by { |error_code, amount| amount["frequency"] }.shift
		end

		def set_phaxio_creds
			Phaxio.api_key = ENV.fetch('PHAXIO_API_KEY')
			Phaxio.api_secret = ENV.fetch('PHAXIO_API_SECRET')
		end
	end
end