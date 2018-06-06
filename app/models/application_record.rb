class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

#Group
 #  def ensure_display_name_exists
	# 	return if self.display_name.present?
	# 	self.display_name = self.group_name
	# end

# Fax
	# def format_fax_number
 #    self.fax_number = Phonelib.parse(fax_number).e164
 #  end

 #  def ensure_is_admin?
 #  	#current_user.is_admin == true, reject if it isn't w/vague error message
 #  end

 
end
