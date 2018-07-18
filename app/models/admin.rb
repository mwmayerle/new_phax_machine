class Admin < User
	has_many :organizations
	has_many :users, through: :organizations
	has_many :fax_numbers, through: :organizations
end