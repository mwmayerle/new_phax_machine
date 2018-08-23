require 'open-uri'

class LogoLink < ApplicationRecord
	validate :logo_url, :validate_logo_url
	LOGO_LINK_LIMIT = 750

	private
		def validate_logo_url
			self.errors.add(:base, "the logo URL is too long.") if logo_url_too_long?
			self.errors.add(:base, "the logo URL must begin with http or https.") if !logo_url_begins_with_http?
			self.errors.add(:base, "the logo URL must link to an image.") if !url_is_image?
		end

		def logo_url_too_long?
			self.logo_url.to_s.length > LOGO_LINK_LIMIT
		end

		def logo_url_begins_with_http?
    	url = URI.parse(self.logo_url) rescue false
    	url.kind_of?(URI::HTTP) || url.kind_of?(URI::HTTPS)
		end

		def url_is_image?
			open(self.logo_url).content_type.start_with?('image') rescue false
		end
end