class Organization < ApplicationRecord
	# -> { with_deleted } links the soft-deleted association. See Paranoia gem docs.
	acts_as_paranoid
	
	include FaxTags
	# include HTTParty
	
	ORGANIZATION_CHARACTER_LIMIT = 42

	attr_readonly :fax_tag, :admin_id

	belongs_to :admin
	belongs_to :manager, optional: true, dependent: :destroy
	has_many :fax_numbers
	has_many :users, -> { with_deleted }, dependent: :destroy
	has_many :user_fax_numbers, through: :users

	validates :label, uniqueness: true, length: { maximum: ORGANIZATION_CHARACTER_LIMIT }, presence: true
	validates :fax_tag, uniqueness: true, length: { maximum: FAX_TAG_LIMIT }, presence: true

	before_validation :ensure_organization_name_not_previously_used, :generate_fax_tag, on: :create
	before_destroy :remove_fax_number_associations

	private
		def remove_fax_number_associations
			self.fax_numbers.each { |fax_number| fax_number.update_attributes(organization_id: nil) } if self.fax_numbers.present?
		end

		def ensure_organization_name_not_previously_used
			if Organization.with_deleted.map { |org| org.label.downcase }.include?(self.label.downcase)
				errors.add(:base, "That name was previously used by another organization. Please use a different name and try again.")
			end
		end

		class << self
			def get_unassigned_users(organization)
				organization.users.select { |organization_user| organization_user.user_fax_numbers.empty? }
			end
		end
end
