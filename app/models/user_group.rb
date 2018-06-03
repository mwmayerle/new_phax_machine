class UserGroup < ApplicationRecord
	belongs_to :user
	belongs_to :group

	validates :user_id, :group_id, presence: true, numericality: {integer_only: true}
end
