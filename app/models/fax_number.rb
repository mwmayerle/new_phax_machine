class FaxNumber < ApplicationRecord
	include FaxOperations

	belongs_to :client, optional: true

	has_one :client_manager, through: :client
	has_one :admin, through: :client

	has_many :fax_number_emails
	has_many :emails, through: :fax_number_emails

	validates :fax_number, presence: true, length: { maximum: 60 }, phone: {possible: true}, uniqueness: true
	validates :fax_number_label, length: { maximum: 60 }
	
	before_validation :fax_number, :format_fax_number

	private
		class << self
			def set_phaxio_creds
				Phaxio.api_key = ENV.fetch('PHAXIO_API_KEY')
				Phaxio.api_secret = ENV.fetch('PHAXIO_API_SECRET')
			end

			def format_cost(cost)
				
				"$".concat("%.2f" % (cost.to_f / 100.00))
			end

			def format_time(time)
				time.to_time.strftime("%l:%M%P %B %-d, %Y")
			end

			def get_account_numbers
				set_phaxio_creds
				api_response = Phaxio::PhoneNumber.list
				phaxio_numbers = {}
				api_response.raw_data.each do |phaxio_number|
					phaxio_numbers[phaxio_number[:phone_number]] = {}
					phaxio_numbers[phaxio_number[:phone_number]][:city] = phaxio_number[:city]
					phaxio_numbers[phaxio_number[:phone_number]][:state] = phaxio_number[:state]
					phaxio_numbers[phaxio_number[:phone_number]][:provisioned_at] = format_time(phaxio_number[:provisioned_at])
					phaxio_numbers[phaxio_number[:phone_number]][:last_billed_at] = format_time(phaxio_number[:last_billed_at])
					phaxio_numbers[phaxio_number[:phone_number]][:cost] = format_cost(phaxio_number[:cost])
				end
				phaxio_numbers
			end

			# Compare all fax numbers associated with the API keys to the fax numbers stored in the database and combine them
			def combine_api_numbers_with_db_numbers(fax_numbers_from_db)
				fax_numbers = {}
				fax_numbers_from_api = get_account_numbers

				fax_numbers_from_db.each do |db_number|
					fax_numbers[db_number.fax_number] = {}

					if db_number.client
						fax_numbers[db_number.fax_number][:client] = db_number.client.client_label
					else
						fax_numbers[db_number.fax_number][:client] = "Unallocated"
					end

					fax_numbers[db_number.fax_number][:fax_number_label] = db_number.fax_number_label

					if fax_numbers_from_api[db_number.fax_number]
						fax_numbers[db_number.fax_number][:phaxio_number] = true
						fax_numbers[db_number.fax_number][:city] = fax_numbers_from_api[db_number.fax_number][:city]
						fax_numbers[db_number.fax_number][:state] = fax_numbers_from_api[db_number.fax_number][:state]
						fax_numbers[db_number.fax_number][:provisioned_at] = fax_numbers_from_api[db_number.fax_number][:provisioned_at]
						fax_numbers[db_number.fax_number][:last_billed_at] = fax_numbers_from_api[db_number.fax_number][:last_billed_at]
						fax_numbers[db_number.fax_number][:cost] = fax_numbers_from_api[db_number.fax_number][:cost]
					else
						fax_numbers[db_number.fax_number][:phaxio_number] = false
					end

				end
				fax_numbers
			end

		end
end
