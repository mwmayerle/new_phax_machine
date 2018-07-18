class UserPermission < ApplicationRecord
	belongs_to :user, optional: true

	USER = 'user'.freeze
  ADMIN = 'admin'.freeze
  MANAGER = 'manager'.freeze
end