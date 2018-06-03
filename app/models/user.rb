class User < ApplicationRecord
	include FaxTags

	attr_readonly :is_admin #prevents other users from updating the "is_admin" boolean if they somehow bypass strong_params

	belongs_to :super_user, optional: true
	has_many :user_groups
	has_many :groups, through: :user_groups

	validates :super_user_id, numericality: {only_integer: true, allow_blank: true}
	validates :email, presence: true, uniqueness: {case_sensitve: false}
	validates :email, :fax_tag, length: {maximum: 60}

	before_save :generate_fax_tag

	has_secure_password	
end
