class Client < ApplicationRecord  #LENGTH_LIMIT constant is in application_record.rb
	include FaxTags

	attr_readonly :admin_id

	belongs_to :admin, class_name: :User
	belongs_to :client_manager, optional: true

	has_many :fax_numbers
	has_many :emails
	has_many :fax_number_emails, through: :emails
	has_many :users

	validates :admin_id, presence: true, numericality: { integer_only: true }
	validates :client_manager_id, numericality: { integer_only: true, allow_blank: true }
	validates :client_label, uniqueness: true, length: { maximum: 32 }, presence: true
	validates :fax_tag, uniqueness: true, length: { maximum: 60 }, presence: true

	before_validation :generate_fax_tag
	# before_destroy :delete_associated

	private
		# def delete_associated
		# 	FaxNumber.where(client_id: self.id).destroy_all
		# 	emails = Email.where(client_id: self.id).destroy_all
		# 	FaxNumberEmail.where(email_id: emails).destroy_all
		# end
end
