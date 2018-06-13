class Client < ApplicationRecord  #LENGTH_LIMIT constant is in application_record.rb
	include FaxOperations

	attr_readonly :admin_id

	belongs_to :admin, class_name: :User
	belongs_to :client_manager, optional: true

	has_many :fax_numbers
	has_many :emails, through: :fax_numbers
	has_many :users

	validates :admin_id, presence: true, numericality: { integer_only: true }
	validates :client_manager_id, numericality: { integer_only: true, allow_blank: true }
	validates :client_label, uniqueness: true, length: { maximum: 32 }, presence: true
	validates :fax_tag, uniqueness: true, length: { maximum: 60 }, presence: true

	before_validation :generate_fax_tag
end
