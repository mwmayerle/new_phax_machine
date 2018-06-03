class User < ApplicationRecord
	include FaxTags

	belongs_to :super_user

	validates :super_user_id, numericality: {only_integer: true}
	validates :user_email, presence: true, uniqueness: {case_sensitve: false}
	validates :user_email, :fax_tag, length: {maximum: 60}

	before_save :generate_fax_tag
	
	has_secure_password	
end
