require 'rails_helper'

# not testing the validity of numbers due to Phonelib's inclusion

RSpec.describe FaxNumber, type: :model do
	let!(:admin) {User.create!(type: :Admin, email: 'testadmin@aol.com', password: 'testadmin')}
	let!(:client_manager) { User.create!(type: :ClientManager, email: 'test_manager@aol.com', password: "testmanager") }
	let!(:client) {Client.create!(admin_id: admin.id, client_manager_id: client_manager.id, client_label: "Fax Number Test Client")}
	let!(:test_group) { Group.create!(group_label: "Fax Model Test Group", client_id: client.id)}
	let!(:fax_number) { client.fax_numbers.new(fax_number: '12248675309', fax_number_label: "Fake Testing Number") }

  describe "valid fax number formatting" do
  	it "persists to the database with valid attributes" do
  		expect(fax_number).to be_valid
  	end

  	it "does not require a fax_number label to still be valid" do
  		fax_number.fax_number_label = nil
  		expect(fax_number).to be_valid
  	end
  end

  describe "invalid fax number formatting" do
  	it "persists to the database only if fax number is present" do
  		fax_number.fax_number = nil
  		expect(fax_number).to be_invalid
  	end

  	it "fax number label cannot be more than 60 characters long" do
  		fax_number.fax_number_label = "A" * 61
  		expect(fax_number).to be_invalid
  	end

  	it "fax_number requires 'faxable' attribute" do
  		fax_number.faxable = nil
  		expect(fax_number).to be_invalid
  	end

  	it "fax_number must be unique" do
  		fake1 = client.fax_numbers.create!(fax_number: '12248671111', fax_number_label: "Fake Testing Number")
  		fake2 = client.fax_numbers.new(fax_number: '12248671111', fax_number_label: "Different Fake Testing Number")
  		expect(fake1).to be_valid
  		expect(fake2).to be_invalid
  	end
  end
end
