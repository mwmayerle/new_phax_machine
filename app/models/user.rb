class User < ApplicationRecord
	include FaxTags

	belongs_to :super_user

	before_save :generate_fax_tag
	has_secure_password	
end
