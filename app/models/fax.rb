class Fax
	class << self
		def get_fax_information(sent_fax_object)
			Phaxio::Fax.get(sent_fax_object.id)
		end

		def create_fax(options)
		  begin
		    sent_fax_response = Phaxio::Fax.create(
		      to: options[:to],
		      file: options[:files],
		      caller_id: options[:caller_id_number],
		      tag: {
		        sender_client_fax_tag: options[:tag][:sender_client_fax_tag], 
		        sender_email_fax_tag: options[:tag][:sender_email_fax_tag]
		      }
		    )
		  rescue => error
		  	sent_fax_response = error.message
		  end
		  sent_fax_response
		end

		def create_fax_from_email(sender, recipient, files)
			puts "==========================="
			p sender
			p recipient
			p files
      p number = Mail::Address.new(recipient).local
      p user_email = UserEmail.find_by(email_address: sender)
			puts "=========================================="

      options = {
      	to: number,
      	caller_id: user_email.caller_id_number,
      	sender_client_fax_tag: user_email.client.fax_tag,
      	sender_email_fax_tag: user_email.fax_tag,
      	files: files.map { |file| File.new(file) }
      }
      p options
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