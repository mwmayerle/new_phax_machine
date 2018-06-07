class Email < ApplicationRecord
	belongs_to :group

	has_one :client, through: :group
	has_one :client_manager, through: :client
	has_one :admin, through: :client

	validates :email, presence: true
	validates :email, length: {maximum: 60}, uniqueness: {case_sensitive: false}
end
