class Admin < User
	has_many :clients
	has_many :groups, through: :clients
	has_many :fax_numbers, through: :groups
	has_many :emails, through: :groups
end
