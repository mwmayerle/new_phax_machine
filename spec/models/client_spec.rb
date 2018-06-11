require 'rails_helper'
RSpec.describe Client, type: :model do
	let!(:admin) {User.create!(type: :Admin, username: "Admin", password: 'testadmin')}
	let!(:client_manager) { User.create!(type: :ClientManager, username: "Test_Manager", password: "testmanager") }
	let!(:client) {Client.new(admin_id: admin.id, client_manager_id: client_manager.id, client_label: "Client Model Test Client", fax_tag: "Test Fax Tag")}

	describe "creating a Client with valid input" do
		it "is valid with valid inputs" do
			expect(client).to be_valid
		end

		it "generates a fax tag if none is provided by the user" do
			client.fax_tag = nil
			client.save
			expect(client.reload.fax_tag).not_to be_nil
		end
	end

	describe "attempting to create a Client with invalid input" do
		it "is invalid if an admin_id is not provided" do
			client.admin_id = nil
			expect(client).to be_invalid
		end

		it "is invalid when the 'fax_tag' attribute is longer than 60 characters" do 
			client.fax_tag = 'A' * 51
			expect(client).to be_invalid
		end

		it "is invalid when the 'client_label' attribute is longer than 60 characters" do 
			client.client_label = 'A' * 51
			expect(client).to be_invalid
		end

		it "the 'fax_tag' attribute must be unique" do
			client.save
			new_client_manager = User.create!(type: :ClientManager, username: "Test_Manager2", password: "testmanager")
			new_client = Client.new(admin_id: admin.id, client_manager_id: client_manager.id, client_label: "Second Client Model Test Client", fax_tag: "Test Fax Tag")
			expect(new_client).to be_invalid
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

		it "is not possible to edit 'the admin_id' attribute" do
			new_client_manager = User.create!(type: :ClientManager, username: "Edit_Admin_Attribute_Test", password: "testmanager", client_id: client.id)
			client.save
			client.update_attributes({ client_label: "An updated client label", client_manager_id: new_client_manager.id, admin_id: new_client_manager.id })
			client.reload
			expect(client.admin_id).to eq(admin.id)
			expect(client.client_manager_id).to eq(new_client_manager.id)
			expect(client.client_label).to eq("An updated client label")
		end
	end
end
