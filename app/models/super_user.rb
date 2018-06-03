class SuperUser < ApplicationRecord
	include FaxTags

	has_one :admin
	has_many :users

	validates :admin_id, numericality: {only_integer: true}
	validates :super_user_email, presence: true, uniqueness: {case_sensitve: false}
	validates :super_user_email, :fax_tag, length: {maximum: 60}
	
	before_save :generate_fax_tag

	has_secure_password
end
