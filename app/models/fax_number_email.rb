class FaxNumberEmail < ApplicationRecord
	belongs_to :email
	belongs_to :fax_number

	validates :email_id, :fax_number_id, presence: true, numericality: { integer_only: true }
end
