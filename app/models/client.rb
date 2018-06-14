class Client < ApplicationRecord  #LENGTH_LIMIT constant is in application_record.rb
	include FaxTags

	attr_readonly :admin_id

	belongs_to :admin, class_name: :User
	belongs_to :client_manager, optional: true, dependent: :destroy

	has_many :fax_numbers
	has_many :emails
	has_many :fax_number_emails, through: :emails
	has_many :users, dependent: :destroy

	validates :admin_id, presence: true, numericality: { integer_only: true }
	validates :client_manager_id, numericality: { integer_only: true, allow_blank: true }
	validates :client_label, uniqueness: true, length: { maximum: 32 }, presence: true
	validates :fax_tag, uniqueness: true, length: { maximum: 60 }, presence: true

	before_validation :generate_fax_tag
	before_destroy :modify_and_delete_associated

	private
		def modify_and_delete_associated
			FaxNumber.where(client_id: self.id).each do |fax_number|
				fax_number.update_attributes( { client_id: nil, fax_number_display_label: nil, fax_number_label: nil } )
			end
			emails = Email.where(client_id: self.id).destroy_all
			FaxNumberEmail.where(email_id: emails).destroy_all
		end
end
