module FaxTags
	def generate_fax_tag
    return if self.fax_tag.present?
    self.fax_tag = SecureRandom.uuid
  end
end