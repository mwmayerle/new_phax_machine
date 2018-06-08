module FaxOperations

	def generate_fax_tag
    return if self.fax_tag.present?
    self.fax_tag = SecureRandom.uuid
  end

  def format_fax_number
		self.fax_number = Phonelib.parse(fax_number).e164
  end
  
end