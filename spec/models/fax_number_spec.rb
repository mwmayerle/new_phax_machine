require 'rails_helper'

RSpec.describe FaxNumber, type: :model do
	let!(:admin) {User.create!(type: :Admin, email: "mwmayerle@gmail.com", password: 'tomtom')}
	let!(:client) {Client.create!(admin_id: admin.id, client_label: "Client Controller Test Client")}
	let!(:client_manager) {User.create!(type: :ClientManager, email: "matt@phaxio.com", client_id: client.id)}
	let!(:user1) {User.create!(email: "user1@gmail.com", client_id: client.id)}
	let!(:fax_number) {FaxNumber.create!(fax_number: '12025550134', fax_number_label: "Fake1", client_id: client.id)}
	let!(:user_email1) {UserEmail.create!(user_id: user1.id, email_address: 'user1@gmail.com', client_id: client.id, caller_id_number: fax_number.fax_number)}
	let!(:user_email2) {UserEmail.create!(user_id: client.id, email_address: 'matt@phaxio.com', client_id: client.id, caller_id_number: fax_number.fax_number)}

	before(:each) { client.update(client_manager_id: client_manager.id) }

  describe "valid fax number formatting" do
  	it "persists to the database with valid attributes" do
  		expect(fax_number).to be_valid
  	end

  	it "does not require a fax_number_label attribute to still be valid" do
  		fax_number.fax_number_label = nil
  		expect(fax_number).to be_valid
  	end
  end

  describe "FaxNumber associations" do
  	before(:each) do
			fax_number.user_emails << user_email1
			fax_number.user_emails << user_email2
  	end

  	it "has one admin" do
			assoc = FaxNumber.reflect_on_association(:admin)
   		expect(assoc.macro).to eq(:has_one)
   		expect(fax_number.admin).to eq(admin)
		end

		it "has one client_manager" do
			assoc = FaxNumber.reflect_on_association(:client_manager)
   		expect(assoc.macro).to eq(:has_one)
   		expect(fax_number.client_manager).to eq(client_manager)
		end

		it "belongs to client" do
			assoc = FaxNumber.reflect_on_association(:client)
   		expect(assoc.macro).to eq(:belongs_to)
   		expect(fax_number.client).to eq(client)
		end

		it "has many fax_number_user_emails" do
			assoc = FaxNumber.reflect_on_association(:fax_number_user_emails)
   		expect(assoc.macro).to eq(:has_many)
   		expect(fax_number.fax_number_user_emails.count).to eq(2)
		end

		it "has many user_emails" do
			assoc = FaxNumber.reflect_on_association(:user_emails)
   		expect(assoc.macro).to eq(:has_many)
   		expect(fax_number.user_emails).to eq([user_email1, user_email2])
		end
  end

  describe "invalid fax number formatting" do
  	it "persists to the database only if fax number is present" do
  		fax_number.fax_number = nil
  		expect(fax_number.save).to be false
  	end

  	it "fax_number_label attribute cannot be more than #{FaxNumber::FAX_NUMBER_CHARACTER_LIMIT} characters long" do
  		fax_number.fax_number_label = "A" * (FaxNumber::FAX_NUMBER_CHARACTER_LIMIT + 1)
  		expect(fax_number).to be_invalid
  	end

  	it "fax_number attribute must be unique" do
  		fake2 = FaxNumber.new(fax_number: '12025550134', fax_number_label: "Different Fake Testing Number")
  		expect(fake2).to be_invalid
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

  describe "#get_unused_emails method" do
  	before(:each) do
			fax_number.user_emails << user_email1
			fax_number.user_emails << user_email2
  	end

  	it "returns user_emails associated with a fax_number " do
  		new_email1 = UserEmail.create(email_address: "test1@gmail.com", caller_id_number: fax_number.fax_number)
  		new_email2 = UserEmail.create(email_address: "test2@gmail.com", caller_id_number: fax_number.fax_number)
  		client.user_emails << new_email1
  		client.user_emails << new_email2
  		client.reload
  		expect(FaxNumber.get_unused_client_emails(fax_number)).to eq([new_email1, new_email2])
  	end
  end
end