class UserPermission < ApplicationRecord
	acts_as_paranoid
	
	belongs_to :user, optional: true

	USER = 'user'.freeze
  ADMIN = 'admin'.freeze
  MANAGER = 'manager'.freeze
end