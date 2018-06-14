class FaxNumberEmail < ApplicationRecord
	belongs_to :email, dependent: :destroy
	belongs_to :fax_number, dependent: :destroy

	validates :email_id, :fax_number_id, presence: true, numericality: { integer_only: true }
end
