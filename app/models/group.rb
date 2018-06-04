class Group < ApplicationRecord

	has_one :group_leader, class_name: "User", foreign_key: "group_leader_id"

	has_many :user_groups
	has_many :users, through: :user_groups

	validates :group_name, presence: true, uniqueness: true, length: {in: 1..60}
	validates :group_leader_id, numericality: {only_integer: true}
	validates :display_name, length: {in: 1..60}

	before_validation :ensure_display_name_exists

	def ensure_display_name_exists
		return if self.display_name.present?
		self.display_name = self.group_name
	end
end
