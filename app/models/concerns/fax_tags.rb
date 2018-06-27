module FaxTags
	FAX_TAG_LIMIT = 60

	def generate_fax_tag
    self.fax_tag = SecureRandom.uuid
  end
  
end