class User < ApplicationRecord
	acts_as_paranoid
	
	include FaxTags

	USER_CHARACTER_LIMIT = 48
	# Include default devise modules. Others available are:
  # :confirmable, :lockable, :trackable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable #:confirmable

  attr_accessor :permission, :logo_url

	belongs_to :organization, optional: true

	has_one :admin, through: :organization
	has_one :manager, through: :organization
	has_one :user_permission, dependent: :destroy
	has_many :user_fax_numbers, dependent: :destroy
	has_many :fax_numbers, through: :user_fax_numbers

	before_validation :generate_fax_tag, :generate_temporary_password, on: :create

	validates :email, presence: true, length: { in: 5..USER_CHARACTER_LIMIT }, uniqueness: { case_senstive: false }
	validates :fax_tag, length: { maximum: FaxTags::FAX_TAG_LIMIT }

	after_create { User.welcome(self.id) }

	accepts_nested_attributes_for :user_permission
	
	private
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

		    if user.permission == UserPermission::MANAGER
		    	PhaxMachineMailer.manager_welcome_invite(user, @raw).deliver_now
		    elsif user.permission == UserPermission::USER
		    	PhaxMachineMailer.user_welcome_invite(user, @raw).deliver_now
		    else
		    	logo = LogoLink.new(logo_url: ENV.fetch("LOGO_URL", nil))
		    	logo.logo_url = nil if logo.logo_url.to_s.length > 1000
		    	logo.save(validate: false)
		    	PhaxMachineMailer.admin_welcome_invite(user, @raw).deliver_now
		    end
		  end
		end
end