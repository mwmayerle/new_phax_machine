require 'rails_helper'

RSpec.describe UserEmail, type: :model do
  let!(:admin) {User.create!(type: :Admin, email: "admin@admin.com", password: 'testadmin')}
	let!(:repeat_client_manager) { User.create!(type: :ClientManager, email: "repeatcm@cm.com", password: "testmanager") }
	let!(:repeat_client) do
		Client.create!(admin_id: admin.id, client_manager_id: repeat_client_manager.id, client_label: "Repeat Client Model Test Client", fax_tag: "Repeat Test Fax Tag")
	end
	let!(:client_manager) { User.create!(type: :ClientManager, email: "cm@cm.com", password: "testmanager") }
	let!(:client) do 
		Client.create!(admin_id: admin.id, client_manager_id: client_manager.id, client_label: "Client Model Test Client", fax_tag: "Test Fax Tag")
	end
	let!(:fax_number) { FaxNumber.create!(fax_number: '12248675309', fax_number_label: "Fake Testing Number", client_id: client.id) }
	let!(:persisted_email) { UserEmail.create!(email_address: 'persisted@phaxio.com', caller_id_number: fax_number.fax_number, client_id: repeat_client.id) }
	let!(:email) { UserEmail.new(email_address: 'test@phaxio.com', caller_id_number: fax_number.fax_number, client_id: client.id) }

	describe "valid email format" do
		it "is valid with valid formatting and generates a fax tag if none is provided" do
			expect(user_email.fax_tag).to be_nil
			expect(user_email).to be_valid
			user_email.save
			expect(user_email.reload.fax_tag).not_to be_nil
		end

		it "does not generate a new fax tag is one is provided by the user" do
			user_email.fax_tag = "New Tag"
			user_email.save
			expect(user_email.reload.fax_tag).to eq("New Tag")
		end
	end

	describe "invalid input" do
		it "does not persist if the fax_tag is longer than 60 characters" do
  		user_email.fax_tag = "A" * 61
  		expect(user_email).to be_invalid
  	end

  	it "is invalid if the email is too long" do
			user_email.email_address = ("A" * 60).concat('@aol.com')
			expect(user_email).to be_invalid
		end

		it "is invalid if the email attribute is nil" do
			user_email.email_address = nil
			expect(user_email).to be_invalid
		end

		it "is invalid if the email already exists" do
			user_email.email_address = 'persisted@phaxio.com'
			expect(user_email).to be_invalid
			user_email.email_address = 'PERSISTED@phaxio.COM'
			expect(email).to be_invalid
		end

		it "is invalid if an admin_id is not provided" do
			user_email.client_id = nil
			expect(email).to be_invalid
		end

		it "is invalid when the 'client_id' attribute is not an integer" do
			user_email.client_id = 'hello'
			expect(email).to be_invalid
			user_email.client_id = 11.22
			expect(email).to be_invalid
		end
	end
end