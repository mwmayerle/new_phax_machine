class FaxNumber < ApplicationRecord
	belongs_to :faxable, polymorphic: true
end
