require 'rails_helper'

RSpec.describe UserEmail, type: :model do
	let!(:admin) {User.create!(type: :Admin, email: "mwmayerle@gmail.com", password: 'tomtom')}
	let!(:client) {Client.create!(admin_id: admin.id, client_label: "Client Controller Test Client")}
	let!(:client_manager) {User.create!(type: :ClientManager, email: "matt@phaxio.com", client_id: client.id)}
	let!(:user1) {User.create!(email: "user1@gmail.com", client_id: client.id)}
	let!(:user2) {User.create!(email: "user2@gmail.com", client_id: client.id)}
	let!(:fax_number1) {FaxNumber.create!(fax_number: '12025550134', fax_number_label: "Fake1", client_id: client.id)}
	let!(:fax_number2) {FaxNumber.create!(fax_number: '12025550121', fax_number_label: "Fake2", client_id: client.id)}

	let!(:user_email1) {UserEmail.create!(user_id: user1.id, email_address: 'user1@gmail.com', client_id: client.id)}
	let!(:user_email2) {UserEmail.new(user_id: user2.id, email_address: 'user2@gmail.com', client_id: client.id)}

	before(:each) { client.update(client_manager_id: client_manager.id) }

	describe "valid email format" do
		it "is valid with valid formatting" do
			expect(user_email2).to be_valid
		end

		it "generates a fax tag if none is provided" do
			expect(user_email2.fax_tag).to be_nil
			user_email2.save
			expect(user_email2.fax_tag).not_to be_nil
		end
	end

	describe "user_email associations" do
		before(:each) do
			user_email2.save
			fax_number1.user_emails << user_email1
			fax_number1.user_emails << user_email2
			fax_number2.user_emails << user_email1
			fax_number2.user_emails << user_email2
  	end

		it "has many fax numbers" do
			assoc = UserEmail.reflect_on_association(:fax_numbers)
   		expect(assoc.macro).to eq(:has_many)
   		expect(user_email1.fax_numbers).to eq([fax_number1, fax_number2])
		end

		it "has one admin" do
			assoc = UserEmail.reflect_on_association(:admin)
   		expect(assoc.macro).to eq(:has_one)
   		expect(user_email1.admin).to eq(admin)
		end

		it "has one client_manager" do
			assoc = UserEmail.reflect_on_association(:client_manager)
   		expect(assoc.macro).to eq(:has_one)
   		expect(user_email1.client_manager).to eq(client_manager)
		end

		it "belongs to client" do
			assoc = UserEmail.reflect_on_association(:client)
   		expect(assoc.macro).to eq(:belongs_to)
   		expect(user_email1.client).to eq(client)
		end

		it "belongs to user" do
			assoc = UserEmail.reflect_on_association(:user)
   		expect(assoc.macro).to eq(:belongs_to)
   		expect(user_email1.user).to eq(user1)
		end

		it "has many fax_number_user_emails" do
			assoc = UserEmail.reflect_on_association(:fax_number_user_emails)
   		expect(assoc.macro).to eq(:has_many)
   		expect(user_email1.fax_number_user_emails.count).to eq(2)
   		expect(user_email2.fax_number_user_emails.count).to eq(2)
   		expect(user_email2.fax_number_user_emails).not_to eq(user_email1.fax_number_user_emails)
		end

		it "removes fax_number_user_emails when the user_email is deleted" do
			expect(client.fax_number_user_emails.count).to eq(4)
			expect {user_email1.destroy}.to change(FaxNumberUserEmail, :count).by(-2)
			expect(client.fax_number_user_emails.count).to eq(2)
		end
	end

	describe "invalid input" do
		it "the fax_tag attribute is read-only" do
			original_fax_tag = user_email1.fax_tag
			user_email1.update_attributes(fax_tag: "edited", email_address: "edited@gmail.com")
			user_email1.reload
			expect(user_email1.email_address).to eq("edited@gmail.com")
			expect(user_email1.fax_tag).to eq(original_fax_tag)
		end

		it "is invalid if the fax_tag is more #{FaxTags::FAX_TAG_LIMIT} characters" do
			user_email1.fax_tag = "a" * (FaxTags::FAX_TAG_LIMIT + 1)
			expect(user_email1).to be_invalid
		end

  	it "is invalid if the email_address is too long" do
			user_email2.email_address = ("A" * UserEmail::USER_EMAIL_CHARACTER_LIMIT).concat('@aol.com')
			expect(user_email2).to be_invalid
		end

		it "is invalid if the email attribute is nil" do
			user_email2.email_address = nil
			expect(user_email2).to be_invalid
		end

		it "is invalid if the email already exists" do
			user_email2.email_address = user_email1.email_address
			expect(user_email2).to be_invalid
		end

		it "is invalid when the 'client_id' attribute is not an integer" do
			user_email1.client_id = 'hello'
			expect(user_email1).to be_invalid
		end
	end
end