class Email < ApplicationRecord
	include FaxTags

	belongs_to :client, dependent: :destroy

	# has_one :admin, through: :client
	has_one :client_manager, through: :client

	has_many :fax_number_emails
	has_many :fax_numbers, through: :fax_number_emails

	validates :email, presence: true, uniqueness: { case_sensitive: false }
	validates :email, :fax_tag, length: { maximum: 60 }
	validates :client_id, presence: true, numericality: { integer_only: true }
	validates :caller_id_number, presence: true, length: { maximum: 60 }, phone: {possible: true}

	validate :caller_id_number, :format_fax_number

	before_validation :generate_fax_tag, :format_fax_number

	private
		def format_fax_number
			self.caller_id_number = Phonelib.parse(caller_id_number).e164
  	end
end