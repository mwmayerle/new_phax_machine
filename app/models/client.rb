class Client < ApplicationRecord
	belongs_to :admin
	belongs_to :client_manager

	has_many :groups
	has_many :users
	
	has_many :fax_numbers, as: :faxable
end
