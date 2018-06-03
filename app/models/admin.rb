class Admin < ApplicationRecord
	
	has_many :super_users

	has_secure_password
end
