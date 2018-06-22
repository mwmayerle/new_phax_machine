class ClientManager < User
	belongs_to :client
	has_many :fax_numbers, through: :client
	has_many :user_emails, through: :client
	has_many :users, through: :client
end
