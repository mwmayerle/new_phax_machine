class Manager < User
	belongs_to :organization
	has_many :fax_numbers, through: :organization
	has_many :users, through: :organization
end
