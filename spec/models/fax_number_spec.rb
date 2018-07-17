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
end