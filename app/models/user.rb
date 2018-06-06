class User < ApplicationRecord
	attr_readonly :type

	before_destroy :ensure_not_admin
	before_validation :generate_fax_tag

	validates :type, :email, presence: true

	belongs_to :client, optional: true

	has_many :user_groups
	has_many :groups, through: :user_groups

	has_one :admin, through: :client
	has_one :client_manager, through: :client

	has_secure_password
	private

	def generate_fax_tag
    return if self.fax_tag.present?
    self.fax_tag = SecureRandom.uuid
  end

  def ensure_not_admin
  	self.errors.add(:base, "Permission denied") if self.type == :admin
  end
end
