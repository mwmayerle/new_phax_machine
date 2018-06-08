class EmailGroup < ApplicationRecord
	belongs_to :email
	belongs_to :group

	validates :email_id, :group_id, presence: true, numericality: { integer_only: true }
end
