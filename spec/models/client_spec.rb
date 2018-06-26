require 'rails_helper'

RSpec.describe Client, :type => :model do

		let!(:admin) {User.create!(type: :Admin, email: "mwmayerle@gmail.com", password: 'tomtom')}
		let!(:client) {Client.create!(admin_id: admin.id, client_label: "Client Controller Test Client")}
		let!(:client_manager) {User.create!(type: :ClientManager, email: "matt@phaxio.com", client_id: client.id)}

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
		it "is invalid if the client_label is more than #{Client::CHARACTER_LIMIT} characters" do
			client.client_label = "a" * (Client::CHARACTER_LIMIT + 1)
			expect(client).not_to be_valid
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
			client.update_attributes({ client_label: "An updated client label", admin_id: client_manager.id })
			client.reload
			expect(client.admin_id).to eq(admin.id)
			expect(client.client_label).to eq("An updated client label")
		end
	end
end