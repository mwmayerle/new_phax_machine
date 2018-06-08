require 'rails_helper'

RSpec.describe EmailGroup, type: :model do
  let!(:admin) {User.create!(type: :Admin, username: "Admin", password: 'testadmin')}
	let!(:client_manager) { User.create!(type: :ClientManager, username: "Client Manager", password: "testmanager") }
	let!(:client) do 
		Client.create!(admin_id: admin.id, client_manager_id: client_manager.id, client_label: "Client Model Test Client", fax_tag: "Test Fax Tag")
	end
	let!(:fax_number) { FaxNumber.create!(fax_number: '12248675309', fax_number_label: "Fake Testing Number", client_id: client.id) }
	let!(:group) do
		Group.create!(group_label: "Phaxio Accounting", display_label: "Accounting", client_id: client.id, fax_tag: "Group Testing Fax Tag", fax_number_id: fax_number.id)
	end
	let!(:email) { Email.create!(email: 'test@phaxio.com', fax_number: fax_number.fax_number, client_id: client.id) }
	let!(:email_group) { EmailGroup.new(group_id: group.id, email_id: email.id) }

	describe "with valid inputs" do
		it "is valid with valid inputs" do
			expect(email_group).to be_valid
		end
	end

	describe "with invalid inputs" do
		it "does not persist if the email_id or the group_id attributes are not integers" do
			email_group.email_id = "one"
			expect(email_group).to be_invalid
			email_group.email_id = 44.2345
			expect(email_group).to be_invalid
			email_group.group_id = "potato"
			expect(email_group).to be_invalid
			email_group.group_id = 1000001.4
			expect(email_group).to be_invalid
		end

		it "does not persist if the email_id or group_id attributes are absent" do
			email_group.email_id = nil
			expect(email_group).to be_invalid
			email_group.email_id = email.id
			email_group.group_id = nil
			expect(email_group).to be_invalid
		end
	end
end