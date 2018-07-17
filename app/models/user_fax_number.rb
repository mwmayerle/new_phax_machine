class UserFaxNumber < ApplicationRecord
	belongs_to :user
	belongs_to :fax_number

	validates :user_id, :fax_number_id, presence: true, numericality: { integer_only: true }
end
