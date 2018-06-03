class SuperUser < ApplicationRecord
	include FaxTags

	has_many :users
	has_many :groups

	validates :super_user_email, presence: true, uniqueness: {case_sensitve: false}
	validates :super_user_email, :fax_tag, length: {maximum: 60}
	
	before_save :generate_fax_tag

	has_secure_password
end
