class Email < ApplicationRecord
	include FaxOperations

	has_many :email_groups
	has_many :groups, through: :email_groups
	has_many :fax_numbers, through: :groups

	belongs_to :client
	has_one :client_manager, through: :client
	has_one :admin, through: :client

	validates :email, presence: true, uniqueness: { case_sensitive: false }
	validates :email, :fax_tag, length: { maximum: 60 }
	validates :client_id, presence: true, numericality: { integer_only: true }

	validate :fax_number, :format_fax_number

	before_validation :generate_fax_tag
end