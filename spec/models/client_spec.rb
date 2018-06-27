require 'rails_helper'

RSpec.describe Client, :type => :model do
		let!(:admin) {User.create!(type: :Admin, email: "mwmayerle@gmail.com", password: 'tomtom')}
		let!(:client) {Client.create!(admin_id: admin.id, client_label: "Client Controller Test Client")}
		let!(:client_manager) {User.create!(type: :ClientManager, email: "matt@phaxio.com", client_id: client.id)}
		let!(:user1) {User.create!(email: "user1@gmail.com", client_id: client.id)}
		let!(:user2) {User.create!(email: "user2@gmail.com", client_id: client.id)}
		let!(:fax_number1) {FaxNumber.create!(fax_number: '12025550134', fax_number_label: "Fake1", client_id: client.id)}
		let!(:fax_number2) {FaxNumber.create!(fax_number: '12025550121', fax_number_label: "Fake2", client_id: client.id)}
		let!(:fax_number3) {FaxNumber.create!(fax_number: '12025550167', fax_number_label: "Fake3", client_id: client.id)}

		let!(:user_email1) {UserEmail.create!(user_id: user1.id, email_address: 'user1@gmail.com', client_id: client.id)}
		let!(:user_email2) {UserEmail.create!(user_id: user2.id, email_address: 'user2@gmail.com', client_id: client.id)}

		(3..9).each do |counter|
			let!("user_email#{counter}".to_sym) {UserEmail.create!(email_address: "user#{counter}@gmail.com", client_id: client.id)}
		end

	before(:each) { client.update(client_manager_id: client_manager.id) }

	describe "creating a Client with valid input" do
		it "is valid with valid inputs" do
			expect(client).to be_valid
		end
	end

	describe "Client callbacks" do
		it "generates a fax tag if none is provided by the user" do
			client.fax_tag = nil
			client.save
			expect(client.reload.fax_tag).not_to be_nil
		end

		it "deletes associated fax_number_user_email data" do
			[user_email1, user_email2, user_email3].each { |user_email| fax_number1.user_emails << user_email}
			[user_email1, user_email4, user_email5, user_email6].each { |user_email| fax_number2.user_emails << user_email}
			[user_email1, user_email7, user_email8, user_email9].each { |user_email| fax_number3.user_emails << user_email}
			expect{ client.destroy }.to change(FaxNumberUserEmail, :count).by(-11)
			expect{ client.destroy }.not_to change(FaxNumber, :count)
		end

		it "deletes associated fax_number_user_email data" do
			expect{ client.destroy }.to change(UserEmail, :count).by(-9)
			expect{ client.destroy }.not_to change(FaxNumber, :count)
		end

		it "makes associated fax_number data nil" do
			client.destroy
			expect(fax_number1.reload.client_id).to be_nil
			expect(fax_number2.reload.client_id).to be_nil
			expect(fax_number3.reload.client_id).to be_nil
		end
	end

	describe "Client assocations" do
		it "has many fax numbers" do
			assoc = Client.reflect_on_association(:fax_numbers)
   		expect(assoc.macro).to eq(:has_many)
   		expect(client.fax_numbers).to eq([fax_number1, fax_number2, fax_number3])
		end

		it "has many user_emails" do
			assoc = Client.reflect_on_association(:user_emails)
   		expect(assoc.macro).to eq(:has_many)
   		expect(client.user_emails).to eq([user_email1, user_email2, user_email3, user_email4, user_email5, user_email6, user_email7, user_email8, user_email9])
		end

		it "has many fax_number_user_emails" do #9 total emails, user_email1 is associated with each number, sum of 11
			[user_email1, user_email2, user_email3].each { |user_email| fax_number1.user_emails << user_email}
			[user_email1, user_email4, user_email5, user_email6].each { |user_email| fax_number2.user_emails << user_email}
			[user_email1, user_email7, user_email8, user_email9].each { |user_email| fax_number3.user_emails << user_email}
			assoc = Client.reflect_on_association(:fax_number_user_emails)
   		expect(assoc.macro).to eq(:has_many)
   		expect(client.fax_number_user_emails.count).to eq(11)
		end

		it "has many users" do
			assoc = Client.reflect_on_association(:users)
   		expect(assoc.macro).to eq(:has_many)
   		expect(client.users).to eq([client_manager, user1, user2])
		end

		it "belongs to the admin" do
			assoc = Client.reflect_on_association(:admin)
   		expect(assoc.macro).to eq(:belongs_to)
   		expect(client.admin).to eq(admin)
		end

		it "belongs to the client_manager" do
			assoc = Client.reflect_on_association(:client_manager)
   		expect(assoc.macro).to eq(:belongs_to)
   		expect(client.client_manager).to eq(client_manager)
		end
	end

	describe "attempting to create a Client with invalid input" do
		it "is invalid if the client_label is more than #{Client::CLIENT_CHARACTER_LIMIT} characters" do
			client.client_label = "a" * (Client::CLIENT_CHARACTER_LIMIT + 1)
			expect(client).not_to be_valid
		end

		it "is invalid if the fax_tag is more #{FaxTags::FAX_TAG_LIMIT} characters" do
			client.fax_tag = "a" * (FaxTags::FAX_TAG_LIMIT + 1)
			expect(client).to be_invalid
		end

		it "is invalid when the 'admin_id' and 'client_manager_id' attributes are not an integer" do
			client.admin_id = 'hello'
			expect(client).to be_invalid
			client.client_manager_id = 'hello again!'
			expect(client).to be_invalid
			client.admin_id = 11.22
			expect(client).to be_invalid
			client.client_manager_id = '18'
			expect(client).to be_invalid
		end

		it "is not possible to edit 'the admin_id' or 'fax_tag' attributes" do
			old_fax_tag = client.fax_tag
			client.update_attributes({ client_label: "An updated client label", admin_id: client_manager.id, fax_tag: 'edited_fax_tag' })
			client.reload
			expect(client.admin_id).to eq(admin.id)
			expect(client.client_label).to eq("An updated client label")
			expect(client.fax_tag).to eq(old_fax_tag)
		end
	end
end