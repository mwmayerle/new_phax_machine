class LogoLink < ApplicationRecord
	validate :logo_url, :check_logo_url_length
	LOGO_LINK_LIMIT = 750

	private
		def check_logo_url_length
			errors.add(:base, "the logo URL is too long.") if self.logo_url.to_s.length > LOGO_LINK_LIMIT
		end
end