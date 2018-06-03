class Group < ApplicationRecord

	has_many :user_groups
	has_many :users, through: :user_groups

	has_one :super_user

	validates :group_name, presence: true, uniqueness: true, length: {in: 1..60}
	validates :super_user_id, numericality: {only_integer: true}
	validates :display_name, length: {in: 1..60}

	before_validation :ensure_display_name_exists

	def ensure_display_name_exists
		return if self.display_name.present?
		self.display_name = self.group_name
	end
end
