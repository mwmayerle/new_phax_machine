class UserEmail < ApplicationRecord
	include FaxTags

	USER_EMAIL_CHARACTER_LIMIT = 60

	attr_readonly :fax_tag

	belongs_to :client, optional: true

	has_one :admin, through: :client
	has_one :client_manager, through: :client
	belongs_to :user, optional: true

	has_many :fax_number_user_emails, dependent: :destroy
	has_many :fax_numbers, through: :fax_number_user_emails

	validates :email_address, :fax_tag, uniqueness: true, presence: true, length: { maximum: USER_EMAIL_CHARACTER_LIMIT }
	validates :client_id, numericality: { integer_only: true, allow_blank: true }
	validate :ensure_caller_id_number_is_client_owned

	before_validation :generate_fax_tag, on: :create

	before_save { self.email_address.downcase! }

	private
		def ensure_caller_id_number_is_client_owned
			if !FaxNumber.where(client_id: self.client_id, fax_number: Phonelib.parse(self.caller_id_number).e164).present?
				errors.add(:caller_id_number, "You do not have permission to use that caller ID number")
			end
		end
end