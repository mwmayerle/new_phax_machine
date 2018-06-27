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

		def send_fax(sender, params_recip, files)
			p "**********************************************************"
			set_phaxio_creds

			# begin
   #      user_id = db[:user_emails].where do |user|
   #        {user.lower(:email) => fromEmail&.downcase}
   #      end.first[:user_id]
   #      user = db[:users].where(id: user_id).first
   #      from_fax_number = user[:fax_number]
   #      fax_tag = user[:fax_tag]
   #    ensure
   #      db.disconnect
   #    end

      number = Mail::Address.new(toEmail).local
      options = {to: number, caller_id: from_fax_number, :"tag[user]" => fax_tag}

      filenames.each_index { |idx| options["filename[#{idx}]"] = File.new(filenames[idx]) }

      logger.info "#{fromEmail} is attempting to send #{filenames.length} files to #{number}..."
      result = Phaxio.send_fax(options)
      result = JSON.parse(result.body)

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