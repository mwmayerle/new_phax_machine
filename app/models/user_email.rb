class UserEmail < ApplicationRecord
	include FaxTags

	belongs_to :client, optional: true

	# has_one :admin, through: :client
	has_one :client_manager, through: :client
	belongs_to :user, optional: true

	has_many :fax_number_user_emails
	has_many :fax_numbers, through: :fax_number_user_emails

	validates :email_address, :fax_tag, uniqueness: true, length: { maximum: 60 }
	validates :client_id, numericality: { integer_only: true, allow_blank: true }

	before_validation :generate_fax_tag
end