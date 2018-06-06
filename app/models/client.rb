class Client < ApplicationRecord
	include FaxTags

	attr_readonly :admin_id

	has_one :admin, class_name: :User
	belongs_to :client_manager

	has_many :groups
	has_many :users
	has_many :fax_numbers, as: :faxable

	validates :admin_id, :client_manager_id, presence: true, numericality: {integer_only: true}
	validates :client_label, :fax_tag, uniqueness: true, length: {maximum: 60, presence: true}

	before_validation :generate_fax_tag
end
