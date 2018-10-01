class UserPermission < ApplicationRecord
	acts_as_paranoid
	
	belongs_to :user, optional: true

	USER = 'user'.freeze
  ADMIN = 'admin'.freeze
  MANAGER = 'manager'.freeze

  before_validation :reject_multiple_admins, if: :admin_permission?

  private
  	def admin_permission?
			self.permission == UserPermission::ADMIN
		end

		def reject_multiple_admins
			errors.add(:base, ApplicationController::DENIED) if UserPermission.where(permission: ADMIN).present?
		end
end