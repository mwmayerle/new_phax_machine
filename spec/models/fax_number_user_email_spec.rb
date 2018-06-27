require 'rails_helper'

RSpec.describe FaxNumberUserEmail, type: :model do
	let!(:admin) {User.create!(type: :Admin, email: "mwmayerle@gmail.com", password: 'tomtom')}
	let!(:client) {Client.create!(admin_id: admin.id, client_label: "Client Controller Test Client")}
	let!(:client_manager) {User.create!(type: :ClientManager, email: "matt@phaxio.com", client_id: client.id)}
	let!(:user1) {User.create!(email: "user1@gmail.com", client_id: client.id)}
	let!(:fax_number) { FaxNumber.create!(fax_number: '12248675309', fax_number_label: "Fake Testing Number", client_id: client.id) }
	let!(:user_email) { UserEmail.create!(user_id: user1.id, email_address: 'test@phaxio.com', caller_id_number: fax_number.fax_number, client_id: client.id) }
	let!(:fax_number_user_email) { FaxNumberUserEmail.new(fax_number_id: fax_number.id, user_email_id: user_email.id) }

	before(:each) { client.update(client_manager_id: client_manager.id) }

	describe "with valid inputs" do
		it "is valid with valid inputs" do
			expect(fax_number_user_email).to be_valid
		end
	end

	describe "FaxNumberUserEmail associations" do
		it "has one user" do
			assoc = FaxNumberUserEmail.reflect_on_association(:user)
   		expect(assoc.macro).to eq(:has_one)
   		expect(fax_number_user_email.user).to eq(user1)
		end

		it "belongs to user_email" do
			assoc = FaxNumberUserEmail.reflect_on_association(:user_email)
   		expect(assoc.macro).to eq(:belongs_to)
   		expect(fax_number_user_email.user_email).to eq(user_email)
		end

		it "belongs to fax_number" do
			assoc = FaxNumberUserEmail.reflect_on_association(:fax_number)
   		expect(assoc.macro).to eq(:belongs_to)
   		expect(fax_number_user_email.fax_number).to eq(fax_number)
		end
	end

	describe "with invalid inputs" do
		it "does not persist if the email_id or the fax_number_id attributes are not integers" do
			fax_number_user_email.user_email_id = "one"
			expect(fax_number_user_email).to be_invalid

			fax_number_user_email.user_email_id = 44.2345
			expect(fax_number_user_email).to be_invalid

			fax_number_user_email.fax_number_id = "potato"
			expect(fax_number_user_email).to be_invalid

			fax_number_user_email.fax_number_id = 1000001.4
			expect(fax_number_user_email).to be_invalid
		end

		it "does not persist if the email_id or fax_number_id attributes are absent" do
			fax_number_user_email.user_email_id = nil
			expect(fax_number_user_email).to be_invalid

			fax_number_user_email.user_email_id = user_email.id
			fax_number_user_email.fax_number_id = nil
			expect(fax_number_user_email).to be_invalid
		end
	end
end