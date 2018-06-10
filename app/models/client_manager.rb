class ClientManager < User
	has_one :client
	has_many :fax_numbers, through: :client
	has_many :emails, through: :client
	has_many :users, through: :client
end
