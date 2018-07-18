class Organization < ApplicationRecord
	include FaxTags
	
	ORGANIZATION_CHARACTER_LIMIT = 48

	attr_readonly :fax_tag, :admin_id

	belongs_to :admin
	belongs_to :manager, optional: true, dependent: :destroy
	has_many :fax_numbers
	has_many :users, dependent: :destroy
	has_many :user_fax_numbers, through: :users

	validates :label, uniqueness: true, length: { maximum: ORGANIZATION_CHARACTER_LIMIT }, presence: true
	validates :fax_tag, uniqueness: true, length: { maximum: FAX_TAG_LIMIT }, presence: true

	before_validation :generate_fax_tag, on: :create

	private
		class << self
			def get_unassigned_users(organization)
				organization.users.select { |organization_user| organization_user.user_fax_numbers.empty? }
			end
		end
end
