class FaxNumber < ApplicationRecord
	include FaxTags

	FAX_NUMBER_CHARACTER_LIMIT = 36
	FAX_NUMBER_DIGIT_LIMIT = 60 # Took this value from Phax Machine, is it real?

	attr_accessor :unassigned_organization_users

	belongs_to :organization, optional: true
	has_one :manager, through: :organization
	has_many :user_fax_numbers
	has_many :users, through: :user_fax_numbers

	validates :fax_number, presence: true, length: { maximum: FAX_NUMBER_DIGIT_LIMIT }, phone: {possible: true}, uniqueness: true
	validates :label, length: { maximum: FAX_NUMBER_CHARACTER_LIMIT }, uniqueness: { allow_nil: true }
	
	before_validation :fax_number, :format_fax_number

	private
		def format_fax_number
			self.fax_number = Phonelib.parse(fax_number).e164
	  end

		class << self
			# Converts '+12223334444' to '(222) 333-4444'
			def format_pretty_fax_number(fax_number)
				fax_number.slice(2, fax_number.length).insert(0,"(").insert(4,") ").insert(9, "-")
			end

			# Converts '210' to '$2.10'
			def format_cost(cost) # this will fail if an integer with many preceding zero's (000020) is used
				"$".concat("%.2f" % (cost / 100.00))
			end

			def format_time(time)
				time.to_time.strftime("%B %-d, %Y")
			end

			# Retrieves all numbers from Phaxio
			def format_and_retrieve_fax_numbers_from_api
				Fax.set_phaxio_creds
				api_response = Phaxio::PhoneNumber.list
				format_fax_numbers(api_response.raw_data)
			end

			# Creates a new hash with desired data from data received from the Phaxio API
			def format_fax_numbers(fax_numbers_from_api, phaxio_numbers = {})
				fax_numbers_from_api.unshift({:phone_number => "+19992146995", :city=>"Las Vegas", :state=>"Nevada", :last_billed_at=>"2018-07-09T11:37:51.000-05:00", :provisioned_at=>"2018-01-09T11:37:50.000-06:00", :cost=>200, :callback_url=>'www.google.com', :id=>4})
				fax_numbers_from_api.each do |api_fax_number|
					phaxio_numbers[api_fax_number[:phone_number]] = {}
					phaxio_numbers[api_fax_number[:phone_number]][:city] = api_fax_number[:city]
					phaxio_numbers[api_fax_number[:phone_number]][:state] = api_fax_number[:state]
					phaxio_numbers[api_fax_number[:phone_number]][:provisioned_at] = format_time(api_fax_number[:provisioned_at])
					phaxio_numbers[api_fax_number[:phone_number]][:cost] = format_cost(api_fax_number[:cost])
					phaxio_numbers[api_fax_number[:phone_number]][:callback_url] = !!api_fax_number[:callback_url]

					db_number = self.find_or_create_by!(fax_number: api_fax_number[:phone_number], has_webhook_url: !!api_fax_number[:callback_url])
					phaxio_numbers[api_fax_number[:phone_number]][:id] = db_number.id

					# Add associated Organization data to hash
					if db_number.organization
						phaxio_numbers[api_fax_number[:phone_number]][:organization] = db_number.organization.label
						phaxio_numbers[api_fax_number[:phone_number]][:organization_id] = db_number.organization.id
					end

					# Updates the saved has_webhook_url boolean column in the database if the database column doesn't
					# match what was pulled down from the Phaxio API. !!nil is false
					if !!db_number[:has_webhook_url] != !!api_fax_number[:callback_url]
						db_number.update_attributes(has_webhook_url: !!api_fax_number[:callback_url])
					end
					phaxio_numbers[api_fax_number[:phone_number]][:label] = db_number.label if db_number.label
				end

				remove_released_fax_numbers(phaxio_numbers)
				sort_fax_numbers_by_callback_url(phaxio_numbers)
			end

			# Removes released numbers from the database and deletes them from the hash created for the table in the index view
			def remove_released_fax_numbers(phaxio_numbers)
				if phaxio_numbers.keys.count != self.count
					deleted_numbers = self.where.not({fax_number: phaxio_numbers.keys}).destroy_all
					phaxio_numbers.each { |deleted_number| phaxio_numbers.delete(deleted_number) }
				end
			end

			# Moves all fax numbers with a fax number specific callback_url attribute to the bottom of the fax_number list
			def sort_fax_numbers_by_callback_url(phaxio_numbers)
				phaxio_numbers = phaxio_numbers.sort_by do |fax_number, data_hash| 
					data_hash[:callback_url] ? 1 : data_hash[:callback_url] <=> data_hash[:callback_url]
				end
				phaxio_numbers.to_h
			end

			def get_unassigned_organization_users(fax_number)
				fax_number.organization.users.select { |organization_user| !organization_user.fax_numbers.include?(fax_number) }
			end
		end
end