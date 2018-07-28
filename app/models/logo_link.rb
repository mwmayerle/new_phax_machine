class LogoLink < ApplicationRecord
	validate :logo_url, :check_logo_url_length

	private
		def check_logo_url_length
			errors.add(:base, "the logo URL is too long.") if self.logo_url.to_s.length > 1000
		end
end