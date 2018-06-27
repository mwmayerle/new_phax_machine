class User < ApplicationRecord
	include FaxTags

	USER = "User"
	ADMIN = "Admin"
	CLIENT_MANAGER = "ClientManager"
	USER_CHARACTER_LIMIT = 60

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :trackable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable #:confirmable

	attr_readonly :type, :fax_tag

	belongs_to :client, optional: true

	has_one :user_email
	has_one :admin, through: :client
	has_one :client_manager, through: :client

	belongs_to :fax_number_user_email, optional: true

	has_many :fax_numbers, through: :client

	validates :email, length: { in: 5..USER_CHARACTER_LIMIT }, uniqueness: { case_senstive: false }
	validates :client_id, presence: true, numericality: { integer_only: true }, if: :is_generic_user?
	validates :situational, length: { maximum: 9, allow_blank: true }
	validates :fax_tag, length: { maximum: FaxTags::FAX_TAG_LIMIT }

	before_validation :ensure_user_type, :check_for_unwanted_characters

	before_validation :generate_fax_tag, :generate_temporary_password, on: :create

	after_create { User.welcome(self.id) }

	before_destroy :remove_client_manager, if: :is_client_manager?
	
	# has_secure_password
	private
		def check_for_unwanted_characters
			errors.add(:email, "Email may not contain spaces") if self.email.match(/\s/)
		end

		def remove_client_manager
			Client.find(self.client.id).update_attributes(client_manager_id: nil)
		end

	  def ensure_user_type
	  	self.type = USER if self.type.nil?
	  end

	  def is_client_manager?
	  	self.type == CLIENT_MANAGER
	  end

	  def is_generic_user?
	  	self.type == USER
	  end

		def generate_temporary_password
			self.password = SecureRandom.uuid
		end

	  class << self
			def welcome(user_id)
		    user = User.find(user_id)
		    @raw = nil
		    raw, enc = Devise.token_generator.generate(user.class, :reset_password_token)
		    user.reset_password_token   = enc
		    user.reset_password_sent_at = Time.now.utc
		    user.save(validate: false)
		    @raw = raw
		    PhaxMachineMailer.welcome_invite(user, @raw).deliver_now
		  end
		end
end