class Admin < ApplicationRecord
	validates :admin_email, uniqueness: {case_sensitve: false}, length: {maximum: 60} #email: true <-- Where did this come from?
	
	has_many :super_users

	has_secure_password
end