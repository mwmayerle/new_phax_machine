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
end