class Group < ApplicationRecord
	belongs_to :client

	has_many :user_groups
	has_many :users, through: :user_groups

	has_one :admin, through: :client
	has_one :client_manager, through: :client
end
