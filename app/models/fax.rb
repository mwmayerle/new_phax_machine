class Fax < ApplicationRecord
	class << self
		def get_fax_information(sent_fax_object)
			Phaxio::Fax.get(sent_fax_object.id)
		end

		def create_fax(options)
			if options[:caller_id].nil?
				sent_fax_response = "Your caller ID number is not set."
			else
			  begin
			    sent_fax_response = Phaxio::Fax.create(
			      to: options[:to],
			      file: options[:files],
			      caller_id: options[:caller_id],
			      tag: {
			        sender_organization_fax_tag: options[:tag][:sender_organization_fax_tag], 
			        sender_email_fax_tag: options[:tag][:sender_email_fax_tag]
			      }
			    )
			  rescue => error
			  	sent_fax_response = error.message
			  end
			end
		  sent_fax_response
		end

		def create_fax_from_email(sender, recipient, files, user)
			set_phaxio_creds
			number = Mail::Address.new(recipient).local
      options = {
      	to: number,
      	caller_id: user.caller_id_number,
      	tag: {
      		sender_organization_fax_tag: user.organization.fax_tag,
      		sender_email_fax_tag: user.fax_tag,
      	},
      	files: files.map { |file| File.new(file) }
      }
      create_fax(options)
    end

		# if there are two error_codes with the same frequency, the error found first (first recipient) takes precedence
		def most_common_error(fax, errors = {})
			fax["recipients"].each do |recipient|
		  	key = recipient["error_message"]
		  	errors.has_key?(key) ? errors[key]["frequency"] += 1 : errors[key] = { "frequency" => 1 }
			end
	  	errors.max_by { |error_code, amount| amount["frequency"] }.shift
		end

		def download_file(id)
	    file = Phaxio::Fax.file(id)
		end

		def set_phaxio_creds
			Phaxio.api_key = ENV.fetch('PHAXIO_API_KEY')
			Phaxio.api_secret = ENV.fetch('PHAXIO_API_SECRET')
			Phaxio.callback_token = ENV.fetch('PHAXIO_CALLBACK_TOKEN')
		end
	end
end