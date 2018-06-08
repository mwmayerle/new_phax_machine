require 'rails_helper'

RSpec.describe FaxNumber, type: :model do
	let!(:admin) {User.create!(type: :Admin, username: "Admin", password: 'testadmin')}
	let!(:client_manager) { User.create!(type: :ClientManager, username: "Client", password: "testmanager") }
	let!(:client) {Client.create!(admin_id: admin.id, client_manager_id: client_manager.id, client_label: "Fax Number Test Client")}
	let!(:fax_number) { FaxNumber.new(fax_number: '12248675309', fax_number_label: "Fake Testing Number", client_id: client.id) }

  describe "valid fax number formatting" do
  	it "persists to the database with valid attributes" do
  		expect(fax_number).to be_valid
  	end

  	it "does not require a fax_number_label attribute to still be valid" do
  		fax_number.fax_number_label = nil
  		expect(fax_number).to be_valid
  	end
  end

  describe "invalid fax number formatting" do
  	it "persists to the database only if fax number is present" do
  		fax_number.fax_number = nil
  		expect(fax_number).to be_invalid
  	end

  	it "fax_number_label attribute cannot be more than 60 characters long" do
  		fax_number.fax_number_label = "A" * 61
  		expect(fax_number).to be_invalid
  	end

  	it "fax_number attribute must be unique" do
  		fake1 = FaxNumber.create!(fax_number: '12248671111', fax_number_label: "Fake Testing Number")
  		fake2 = FaxNumber.new(fax_number: '12248671111', fax_number_label: "Different Fake Testing Number")
  		expect(fake1).to be_valid
  		expect(fake2).to be_invalid
  	end
  end
end
