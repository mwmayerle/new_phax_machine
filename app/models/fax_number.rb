class FaxNumber < ApplicationRecord
	belongs_to :faxable, polymorphic: true

	validates :fax_number, presence: true, length: {maximum: 60}, phone: {possible: true}, uniqueness: true
	validates :fax_number_label, length: {maximum: 60}
end
