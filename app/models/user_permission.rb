class UserPermission < ApplicationRecord
	belongs_to :user

	USER = 'user'.freeze
  ADMIN = 'admin'.freeze
  MANAGER = 'manager'.freeze
  SUPERADMIN = 'superadmin'.freeze
end