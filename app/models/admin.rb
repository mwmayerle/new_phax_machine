class Admin < User
	has_many :fax_numbers, as: :faxable
	has_many :clients
end
