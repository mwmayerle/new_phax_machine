class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
# User types:
  ADMIN = "Admin"
  CLIENT_MANAGER = "ClientManager"
  USER = "User"
end
