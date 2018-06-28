class Fax
	class << self
		# if there are two error_codes with the same frequency of occurrance, the error found first (first recipient) takes precedence
		def most_common_error(fax, errors = {})
			fax["recipients"].each do |recipient|
		  	key = recipient["error_code"]
		  	errors.has_key?(key) ? errors[key]["frequency"] += 1 : errors[key] = {"frequency" => 1}
			end
	  	errors.max_by {|error_code, amount| amount["frequency"]}.shift
		end

		def get_fax_information(sent_fax_object)
			Phaxio::Fax.get(sent_fax_object.get.id)
		end

		def create_fax(to, attached_files, caller_id, sender_client_fax_tag, sender_email_fax_tag)
			Phaxio::Fax.create(
				to: to,
				file: attached_files,
				caller_id: caller_id_number,
				tag: {
					sender_client_fax_tag: sender_client_fax_tag,
					sender_email_fax_tag: sender_email_fax_tag,
				},
			)
		end

		def send_fax_from_email(sender, recipient, files)
			p "**********************************************************"
			set_phaxio_creds
			user_email = UserEmail.find_by(email: sender.downcase)
      number = Mail::Address.new(recipient).local

      options = {
      	to: number,
      	caller_id: user_email.caller_id_number,
      	sender_client_fax_tag: user_email.client.fax_tag,
      	send_email_fax_tag: user_email.fax_tag,
      	file: files.map { |file| File.new(file) }
      }

      p "**********************************************************"
      p options
      logger.info "#{sender} is attempting to send #{files.length} files to #{number}..."
      result = create_fax(options)
      result = JSON.parse(result.body)
      p result
      if result['success']
        logger.info "Fax queued up successfully: ID #" + result['data']['faxId'].to_s
      else
        logger.warn "Problem submitting fax: " + result['message']

        # if ENV['SMTP_HOST']
        #   #send mail back to the user telling them there was a problem

        #   Pony.mail(
        #     :to => fromEmail,
        #     :from => smtp_from_address,
        #     :subject => 'Mailfax: There was a problem sending your fax',
        #     :body => "There was a problem faxing your #{filenames.length} files to #{number}: " + result['message'],
        #     :via => :smtp,
        #     :via_options => smtp_options
        #   )
        # end
      end
		end
	end
	
	protected
		class << self
			def set_phaxio_creds
				Phaxio.api_key = ENV.fetch('PHAXIO_API_KEY')
				Phaxio.api_secret = ENV.fetch('PHAXIO_API_SECRET')
			end
		end
end