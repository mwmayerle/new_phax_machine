class FaxNumber < ApplicationRecord
	belongs_to :admin, class_name: "User"
	
	validates :fax_number, presence: true, length: {maximum: 60}, phone: {possible: true}, uniqueness: true
	validates :fax_number_label, length: {maximum: 60}
	validates :admin_id, presence: true, numericality: {integer_only: true}

	before_validation :format_fax_number, :ensure_is_admin?

	private	
		def format_fax_number
	    self.fax_number = Phonelib.parse(fax_number).e164
	  end

	  def ensure_is_admin?
	  	#current_user.is_admin == true, reject if it isn't w/vague error message
	  end
end
