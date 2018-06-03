class SuperUser < ApplicationRecord
	include FaxTags

	has_one :admin
	has_many :users
	
	before_save :generate_fax_tag

	has_secure_password
end
