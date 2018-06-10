class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  LENGTH_LIMIT = 50
end
