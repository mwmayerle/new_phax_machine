class FaxNumberUserEmail < ApplicationRecord
	belongs_to :user_email
	belongs_to :fax_number

	has_one :user, through: :user_email

	validates :user_email_id, :fax_number_id, presence: true, numericality: { integer_only: true }
end
