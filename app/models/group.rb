class Group < ApplicationRecord
	include FaxTags

	belongs_to :client
	belongs_to :fax_number
	
	has_many :emails
	has_many :users, through: :client

	has_one :admin, through: :client
	has_one :client_manager, through: :client

	validates :client_id, numericality: { integer_only: true }, presence: true
	validates :group_label, :display_label, :fax_tag, length: { maximum: 60 }
	validates :group_label, :fax_tag, presence: true, uniqueness: true

	before_validation :ensure_display_label_exists, :generate_fax_tag

  def ensure_display_label_exists
		return if self.display_label.present?
		self.display_label = self.group_label
	end
end
