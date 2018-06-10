require 'rails_helper'

RSpec.describe Email, type: :model do
  let!(:admin) {User.create!(type: :Admin, username: "Admin", password: 'testadmin')}
	let!(:repeat_client_manager) { User.create!(type: :ClientManager, username: "Repeat Client Manager", password: "testmanager") }
	let!(:repeat_client) do
		Client.create!(admin_id: admin.id, client_manager_id: repeat_client_manager.id, client_label: "Repeat Client Model Test Client", fax_tag: "Repeat Test Fax Tag")
	end
	let!(:client_manager) { User.create!(type: :ClientManager, username: "Client Manager", password: "testmanager") }
	let!(:client) do 
		Client.create!(admin_id: admin.id, client_manager_id: client_manager.id, client_label: "Client Model Test Client", fax_tag: "Test Fax Tag")
	end
	let!(:fax_number) { FaxNumber.create!(fax_number: '12248675309', fax_number_label: "Fake Testing Number", client_id: client.id) }
	let!(:persisted_email) { Email.create!(email: 'persisted@phaxio.com', fax_number: fax_number.fax_number, client_id: repeat_client.id) }
	let!(:email) { Email.new(email: 'test@phaxio.com', fax_number: fax_number.fax_number, client_id: client.id) }

	describe "valid email format" do
		it "is valid with valid formatting and generates a fax tag if none is provided" do
			expect(email.fax_tag).to be_nil
			expect(email).to be_valid
			email.save
			expect(email.reload.fax_tag).not_to be_nil
		end

		it "does not generate a new fax tag is one is provided by the user" do
			email.fax_tag = "New Tag"
			email.save
			expect(email.reload.fax_tag).to eq("New Tag")
		end
	end

	describe "invalid input" do
		it "does not persist if the fax_tag is longer than 60 characters" do
  		email.fax_tag = "A" * 61
  		expect(email).to be_invalid
  	end

  	it "is invalid if the email is too long" do
			email.email = ("A" * 60).concat('@aol.com')
			expect(email).to be_invalid
		end

		it "is invalid if the email attribute is nil" do
			email.email = nil
			expect(email).to be_invalid
		end

		it "is invalid if the email already exists" do
			email.email = 'persisted@phaxio.com'
			expect(email).to be_invalid
			email.email = 'PERSISTED@phaxio.COM'
			expect(email).to be_invalid
		end

		it "is invalid if an admin_id is not provided" do
			email.client_id = nil
			expect(email).to be_invalid
		end

		it "is invalid when the 'client_id' attribute is not an integer" do
			email.client_id = 'hello'
			expect(email).to be_invalid
			email.client_id = 11.22
			expect(email).to be_invalid
		end
	end
end