class User < ApplicationRecord
	include FaxOperations

	attr_readonly :type

	belongs_to :client, optional: true

	has_one :admin, through: :client
	has_one :client_manager, through: :client

	validates :username, length: { in: 5..LENGTH_LIMIT }, uniqueness: { case_senstive: false }
	validates :fax_tag, length: { maximum: LENGTH_LIMIT }, uniqueness: { case_sensitve: false }
	validates :client_id, presence: true, numericality: { integer_only: true }, if: :is_generic_user?

	before_validation :generate_fax_tag, :ensure_user_type, :remove_unwanted_characters
	has_secure_password

	private
		def remove_unwanted_characters
			self.errors.add(:username, "Username may not contain any spaces") if self.username.match(/\s/)
		end

	  def ensure_user_type
	  	self.type = "User" if self.type.nil?
	  end

	  def is_generic_user?
	  	self.type == "User"
	  end
end