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
	end
	
	protected
		class << self
			def set_phaxio_creds
				Phaxio.api_key = ENV.fetch('PHAXIO_API_KEY')
				Phaxio.api_secret = ENV.fetch('PHAXIO_API_SECRET')
			end
		end
end