class User < ApplicationRecord
	include FaxTags

	attr_readonly :type

	before_destroy :ensure_admin
	before_validation :generate_fax_tag, :ensure_user_type

	validates :email, presence: true
	validates :email, length: {maximum: 60}, uniqueness: {case_sensitive: false}
	validates :fax_tag, length: {maximum: 60}, uniqueness: {case_sensitve: false}

	belongs_to :client, optional: true

	has_many :user_groups
	has_many :groups, through: :user_groups

	has_one :admin, through: :client
	has_one :client_manager, through: :client

	has_secure_password
	private

  def ensure_admin
  	self.errors.add(:base, "Permission denied") if self.type != :admin
  end

  def ensure_user_type
  	self.type = :User if self.type.nil?
  end
end