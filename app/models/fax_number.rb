class FaxNumber < ApplicationRecord
	include FaxOperations #in model/concerns folder

	belongs_to :client, optional: true

	has_one :client_manager, through: :client
	has_one :admin, through: :client

	has_many :fax_number_emails
	has_many :emails, through: :fax_number_emails

	validates :fax_number, presence: true, length: { maximum: LENGTH_LIMIT }, phone: {possible: true}, uniqueness: true
	validates :fax_number_label, length: { maximum: LENGTH_LIMIT }
	
	before_validation :fax_number, :format_fax_number

	private
		class << self
			def set_phaxio_creds
				Phaxio.api_key = ENV.fetch('PHAXIO_API_KEY')
				Phaxio.api_secret = ENV.fetch('PHAXIO_API_SECRET')
			end

			def format_cost(cost) # this will fail if an integer with many preceding zero's (000020) is used
				"$".concat("%.2f" % (cost / 100.00))
			end

			def format_time(time)
				time.to_time.strftime("%B %-d, %Y")
			end

			def format_and_retrieve_fax_numbers_from_api
				set_phaxio_creds
				api_response = Phaxio::PhoneNumber.list
				format_fax_numbers(api_response.raw_data)
			end

			def format_fax_numbers(fax_numbers_from_api)
				phaxio_fax_numbers = {}
				fax_numbers_from_api.each do |api_fax_number|
					phaxio_fax_numbers[api_fax_number[:phone_number]] = {}
					phaxio_fax_numbers[api_fax_number[:phone_number]][:city] = api_fax_number[:city]
					phaxio_fax_numbers[api_fax_number[:phone_number]][:state] = api_fax_number[:state]
					phaxio_fax_numbers[api_fax_number[:phone_number]][:provisioned_at] = format_time(api_fax_number[:provisioned_at])
					phaxio_fax_numbers[api_fax_number[:phone_number]][:cost] = format_cost(api_fax_number[:cost])

					db_number = self.find_or_create_by!(fax_number: api_fax_number[:phone_number])
					phaxio_fax_numbers[api_fax_number[:phone_number]][:id] = db_number.id

					if db_number.client
						phaxio_fax_numbers[api_fax_number[:phone_number]][:client] = db_number.client.client_label
					else
						phaxio_fax_numbers[api_fax_number[:phone_number]][:client] = "Unallocated"
					end
					
					phaxio_fax_numbers[api_fax_number[:phone_number]][:fax_number_label] = db_number.fax_number_label if db_number.fax_number_label
				end
				phaxio_fax_numbers
			end
		end
end
