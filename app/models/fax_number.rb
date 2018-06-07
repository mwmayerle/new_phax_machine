class FaxNumber < ApplicationRecord
	belongs_to :client

	has_one :group
	has_one :client_manager, through: :client
	has_one :admin, through: :client

	has_many :emails, through: :group

	validates :fax_number, presence: true, length: {maximum: 60}, phone: {possible: true}, uniqueness: true
	validates :fax_number_label, length: {maximum: 60}
end
