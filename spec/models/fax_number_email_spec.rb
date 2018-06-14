require 'rails_helper'

RSpec.describe FaxNumberEmail, type: :model do
  let!(:admin) {User.create!(type: :Admin, username: "Admin", password: 'testadmin')}
	let!(:client_manager) { User.create!(type: :ClientManager, username: "Client_Manager", password: "testmanager") }
	let!(:client) do 
		Client.create!(admin_id: admin.id, client_manager_id: client_manager.id, client_label: "Client Model Test Client", fax_tag: "Test Fax Tag")
	end
	let!(:fax_number) { FaxNumber.create!(fax_number: '12248675309', fax_number_label: "Fake Testing Number", client_id: client.id) }
	let!(:email) { Email.create!(email: 'test@phaxio.com', caller_id_number: fax_number.fax_number, client_id: client.id) }
	let!(:fax_number_email) { FaxNumberEmail.new(fax_number_id: fax_number.id, email_id: email.id) }

	describe "with valid inputs" do
		it "is valid with valid inputs" do
			expect(fax_number_email).to be_valid
		end
	end

	describe "with invalid inputs" do
		it "does not persist if the email_id or the fax_number_id attributes are not integers" do
			fax_number_email.email_id = "one"
			expect(fax_number_email).to be_invalid
			fax_number_email.email_id = 44.2345
			expect(fax_number_email).to be_invalid
			fax_number_email.fax_number_id = "potato"
			expect(fax_number_email).to be_invalid
			fax_number_email.fax_number_id = 1000001.4
			expect(fax_number_email).to be_invalid
		end

		it "does not persist if the email_id or fax_number_id attributes are absent" do
			fax_number_email.email_id = nil
			expect(fax_number_email).to be_invalid
			fax_number_email.email_id = email.id
			fax_number_email.fax_number_id = nil
			expect(fax_number_email).to be_invalid
		end
	end
end
