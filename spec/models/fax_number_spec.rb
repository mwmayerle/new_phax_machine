require 'rails_helper'

RSpec.describe FaxNumber, type: :model do
	let! (:admin) do User.create!(
		email: 'fake@phaxio.com',
		user_permission_attributes: { permission: UserPermission::ADMIN }
	)
	end
	let!(:org) { Organization.create(label: "Phaxio Test Company", admin_id: admin.id) }
	let!(:manager) do 
		User.create!(
			email: 'manager@phaxio.com',
			user_permission_attributes: { permission: UserPermission::MANAGER },
			caller_id_number: '17738675309',
			organization_id: org.id
		)
	end
	let!(:user1) do 
		User.create!(
			email: 'matt@phaxio.com',
			user_permission_attributes: { permission: UserPermission::USER },
			caller_id_number: '17738675309',
			organization_id: org.id
		)
	end
	let!(:user2) do 
		User.create!(
			email: 'helloworld@phaxio.com',
			user_permission_attributes: { permission: UserPermission::USER },
			caller_id_number: '17738675309',
			organization_id: org.id
		)
	end
	let!(:fax_number) { FaxNumber.new(fax_number: '17738675309', organization_id: org.id) }

	before(:each) { org.update(manager_id: manager.id) }

  describe "valid fax number formatting" do
  	it "persists to the database with valid attributes" do
  		expect(fax_number).to be_valid
  	end

  	it "does not require a label attribute to still be valid" do
  		fax_number.label = nil
  		expect(fax_number).to be_valid
  	end
  end

  describe "FaxNumber associations" do
  	before(:each) do
  		fax_number.save
			fax_number.users << user1
			fax_number.users << user2
  	end

		it "has one manager" do
			assoc = FaxNumber.reflect_on_association(:manager)
   		expect(assoc.macro).to eq(:has_one)
   		expect(fax_number.manager).to eq(org.manager)
		end

		it "belongs to organization" do
			assoc = FaxNumber.reflect_on_association(:organization)
   		expect(assoc.macro).to eq(:belongs_to)
   		expect(fax_number.organization).to eq(org)
		end

		it "has many UserFaxNumbers" do
			assoc = FaxNumber.reflect_on_association(:user_fax_numbers)
   		expect(assoc.macro).to eq(:has_many)
   		expect(fax_number.user_fax_numbers.count).to eq(2)
		end
  end

  describe "invalid fax number formatting" do
  	it "persists to the database only if fax number is present" do
  		fax_number.fax_number = nil
  		expect(fax_number).to be_invalid
  	end

  	it "label attribute cannot be more than #{FaxNumber::FAX_NUMBER_CHARACTER_LIMIT} characters long" do
  		fax_number.label = "A" * (FaxNumber::FAX_NUMBER_CHARACTER_LIMIT + 1)
  		expect(fax_number).to be_invalid
  	end

  	it "fax_number attribute must be unique" do
  		fax_number.save
  		fax_number2 = FaxNumber.new(fax_number: '17738675309', label: "Different Fake Testing Number")
  		expect(fax_number2).to be_invalid
  	end
  end

  describe "#format_cost method" do
  	it "returns a properly formatted string" do
  		expect(FaxNumber.format_cost(1)).to eq("$0.01")
  		expect(FaxNumber.format_cost(20)).to eq("$0.20")
  		expect(FaxNumber.format_cost(207)).to eq("$2.07")
  		expect(FaxNumber.format_cost(111)).to eq("$1.11")
  		expect(FaxNumber.format_cost(1000)).to eq("$10.00")
  		expect(FaxNumber.format_cost(99999)).to eq("$999.99")
  	end
  end

  describe "#format_fax_number method" do
		fake_number1 = {:phone_number => "+14442146849", :city=>"St. Louis", :state=>"Missouri", :last_billed_at=>"2018-07-09T11:37:51.000-05:00", :provisioned_at=>"2017-11-09T11:37:50.000-06:00", :cost=>200, :callback_url=>'www.helloworld.com', :id=>8}
		fake_number2 = {:phone_number => "+14442146848", :city=>"Chicago", :state=>"Illinois", :last_billed_at=>"2018-07-09T11:37:51.000-05:00", :provisioned_at=>"2015-08-09T11:37:50.000-06:00", :cost=>200, :callback_url=>nil, :id=>5}
		fake_number3 = {:phone_number => "+14442146845", :city=>"San Antonio", :state=>"Texas", :last_billed_at=>"2018-07-09T11:37:51.000-05:00", :provisioned_at=>"2018-01-09T11:37:50.000-06:00", :cost=>200, :callback_url=>'www.weeeeee.com', :id=>5} 
		fake_number4 = {:phone_number => "+14442146995", :city=>"San Francisco", :state=>"California", :last_billed_at=>"2018-07-09T11:37:51.000-05:00", :provisioned_at=>"2018-01-09T11:37:50.000-06:00", :cost=>200, :callback_url=>nil, :id=>4}
		fake_number5 = {:phone_number => "+19992146995", :city=>"Las Vegas", :state=>"Nevada", :last_billed_at=>"2018-07-09T11:37:51.000-05:00", :provisioned_at=>"2018-01-09T11:37:50.000-06:00", :cost=>200, :callback_url=>'www.google.com', :id=>4}
		fax_numbers_from_api = [fake_number1, fake_number2, fake_number3, fake_number4, fake_number5]

  	it "deletes fax numbers that are not in the api response from the database and from the hash being sent to the index view" do
  		fax_number.save
  		phaxio_numbers = FaxNumber.format_fax_numbers(fax_numbers_from_api)
  		expect(phaxio_numbers).not_to include(fax_number)
  		expect(FaxNumber.all).not_to include(fax_number)
  	end

  	it "sorts all fax numbers and puts fax numbers with an associated callback_url at the bottom of the list (end of the array)" do
  		phaxio_numbers = FaxNumber.format_fax_numbers(fax_numbers_from_api)
  		expect(phaxio_numbers.keys[0..1]).to include(fake_number2[:phone_number], fake_number4[:phone_number])
  		expect(phaxio_numbers.keys[2..4]).to include(fake_number1[:phone_number], fake_number3[:phone_number], fake_number5[:phone_number])
  	end
  end
end

