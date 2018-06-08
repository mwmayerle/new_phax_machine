class ClientManager < User
	has_one :client
	has_many :groups, through: :client
	has_many :fax_numbers, through: :groups
	has_many :emails, through: :groups
	has_many :users, through: :client
end
