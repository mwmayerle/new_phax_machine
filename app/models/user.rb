class User < ApplicationRecord
	include FaxTags
 	# attr_readonly prevents other users from updating the "is_admin" or "is_group_leader" boolean if they somehow bypass the param whitelisting
	attr_readonly :is_admin
	attr_readonly :is_group_leader

	belongs_to :admin, class_name: "User", optional: true
	belongs_to :group_leader, class_name: "User", optional: true
	
	has_many :fax_numbers
	has_many :user_groups
	has_many :groups, through: :user_groups

	validates :group_leader_id, numericality: {only_integer: true, allow_blank: true}
	validates :email, presence: true, uniqueness: {case_sensitve: false}
	validates :email, :fax_tag, length: {maximum: 60}

	before_save :generate_fax_tag

	has_secure_password	
end