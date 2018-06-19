class UserEmail < ApplicationRecord
	include FaxTags

	belongs_to :client, optional: true

	# has_one :admin, through: :client
	has_one :client_manager, through: :client
	has_one :user

	has_many :fax_number_user_emails
	has_many :fax_numbers, through: :fax_number_user_emails

	validates :fax_tag, length: { maximum: 60 }
	validates :client_id, numericality: { integer_only: true, allow_blank: true }
	# validates :caller_id_number, length: { maximum: 60 }, phone: { possible: true } if: { self.caller_id_number }
	# validate :caller_id_number, :format_fax_number

	before_validation :generate_fax_tag, :format_fax_number

	private
		def format_fax_number
			self.caller_id_number = Phonelib.parse(caller_id_number).e164
  	end
end