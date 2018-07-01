class FaxNumberUserEmail < ApplicationRecord
	belongs_to :user_email
	belongs_to :fax_number

	has_one :user, through: :user_email

	validates :user_email_id, :fax_number_id, presence: true, numericality: { integer_only: true }

	validate :ensure_no_duplicates

	private
		def ensure_no_duplicates
			possible_duplicates = FaxNumberUserEmail.where(fax_number_id: self.fax_number_id, user_email_id: self.user_email_id)
			errors.add(:base, "Emails cannot be linked to same fax number multiple times") if possible_duplicates.present?
		end
end
