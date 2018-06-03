class FaxNumber < ApplicationRecord
	
	validates :fax_number, presence: true, length: {maximum: 60}, phone: {possible: true}, uniqueness: true
	validates :fax_number_label, length: {maximum: 48}

	before_validation :format_fax_number

	private	
		def format_fax_number
	    self.fax_number = Phonelib.parse(fax_number).e164
	  end
end
