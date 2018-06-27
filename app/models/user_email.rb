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

	before_validation :generate_fax_tag, on: :create

	before_destroy :ensure_client_manager_cannot_delete_self, if: :is_client_manager?

	private
		def ensure_client_manager_cannot_delete_self
			if self.user == current_user
				errors.add(:base, "Client Manager email cannot be deleted by the client manager")
			end
		end

		def is_client_manager?
			self.user.type == User::CLIENT_MANAGER
		end
end