class FaxNumber < ApplicationRecord
	include FaxTags

	FAX_NUMBER_CHARACTER_LIMIT = 36
	FAX_NUMBER_DIGIT_LIMIT = 60 # Took this value from Phax Machine, is it real?

	attr_accessor :unused_client_emails

	belongs_to :client, optional: true

	has_one :client_manager, through: :client
	has_one :admin, through: :client

	has_many :fax_number_user_emails
	has_many :user_emails, through: :fax_number_user_emails

	validates :fax_number, presence: true, length: { maximum: FAX_NUMBER_DIGIT_LIMIT }, phone: {possible: true}, uniqueness: true
	validates :fax_number_label, length: { maximum: FAX_NUMBER_CHARACTER_LIMIT }
	
	before_validation :fax_number, :format_fax_number

	private
		def format_fax_number
			self.fax_number = Phonelib.parse(fax_number).e164
	  end

		class << self
			def format_cost(cost) # this will fail if an integer with many preceding zero's (000020) is used
				"$".concat("%.2f" % (cost / 100.00))
			end

			def format_time(time)
				time.to_time.strftime("%B %-d, %Y")
			end

			def format_and_retrieve_fax_numbers_from_api
				Fax.set_phaxio_creds
				api_response = Phaxio::PhoneNumber.list
				format_fax_numbers(api_response.raw_data)
			end

			def format_fax_numbers(fax_numbers_from_api, phaxio_numbers = {})
				fax_numbers_from_api.each do |api_fax_number|
					phaxio_numbers[api_fax_number[:phone_number]] = {}
					phaxio_numbers[api_fax_number[:phone_number]][:city] = api_fax_number[:city]
					phaxio_numbers[api_fax_number[:phone_number]][:state] = api_fax_number[:state]
					phaxio_numbers[api_fax_number[:phone_number]][:provisioned_at] = format_time(api_fax_number[:provisioned_at])
					phaxio_numbers[api_fax_number[:phone_number]][:cost] = format_cost(api_fax_number[:cost])

					db_number = self.find_or_create_by!(fax_number: api_fax_number[:phone_number])
					phaxio_numbers[api_fax_number[:phone_number]][:id] = db_number.id

					if db_number.client
						phaxio_numbers[api_fax_number[:phone_number]][:client] = db_number.client.client_label
					else
						phaxio_numbers[api_fax_number[:phone_number]][:client] = "Unallocated"
					end
					
					phaxio_numbers[api_fax_number[:phone_number]][:fax_number_label] = db_number.fax_number_label if db_number.fax_number_label
				end
				phaxio_numbers
			end

			def get_unused_client_emails(fax_number)
				fax_number.client.user_emails.select { |client_email| !client_email.fax_numbers.include?(fax_number) }
			end
		end
end
