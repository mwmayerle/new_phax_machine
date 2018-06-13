class Email < ApplicationRecord
	include FaxOperations

	belongs_to :client

	# has_one :admin, through: :client
	has_one :client_manager, through: :client

	has_many :fax_number_emails
	has_many :fax_numbers, through: :fax_number_emails

	validates :email, presence: true, uniqueness: { case_sensitive: false }
	validates :email, :fax_tag, length: { maximum: 60 }
	validates :client_id, presence: true, numericality: { integer_only: true }

	validate :fax_number, :format_fax_number

	before_validation :generate_fax_tag
end