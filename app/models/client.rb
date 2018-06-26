class Client < ApplicationRecord
	CHARACTER_LIMIT = 36
	include FaxTags

	attr_readonly :admin_id, :fax_tag

	belongs_to :admin, class_name: :User
	belongs_to :client_manager, optional: true, dependent: :destroy

	has_many :fax_numbers
	has_many :user_emails
	has_many :fax_number_user_emails, through: :user_emails
	has_many :users, dependent: :destroy

	validates :admin_id, presence: true, numericality: { integer_only: true }
	validates :client_manager_id, numericality: { integer_only: true, allow_blank: true }
	validates :client_label, uniqueness: true, length: { maximum: CHARACTER_LIMIT }, presence: true
	validates :fax_tag, uniqueness: true, length: { maximum: CHARACTER_LIMIT }, presence: true

	before_validation :generate_fax_tag
	before_destroy :modify_and_delete_associated

	private
		def modify_and_delete_associated
			FaxNumber.where(client_id: self.id).each do |fax_number|
				fax_number.update_attributes( { client_id: nil, fax_number_display_label: nil, fax_number_label: nil } )
			end
			user_emails = UserEmail.where(client_id: self.id).destroy_all
			FaxNumberUserEmail.where(user_email_id: user_emails).destroy_all
		end
end
