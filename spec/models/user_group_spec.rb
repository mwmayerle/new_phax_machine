require 'rails_helper'

RSpec.describe UserGroup, type: :model do
	let!(:admin) {User.create!(type: :Admin, email: 'testadmin@aol.com', password: 'testadmin')}
	let!(:client_manager) { User.create!(type: :ClientManager, email: 'test_manager@aol.com', password: "testmanager") }
	let!(:user) { User.create!(email: 'tom@tom.com', password: "tomtom", fax_tag: "tomtag") }
	let!(:client) {Client.create!(admin_id: admin.id, client_manager_id: client_manager.id, client_label: "Client Model Test Client", fax_tag: "Test Fax Tag")}
	let!(:group) { Group.create!(group_label: "Phaxio Accounting", display_label: "Accounting", client_id: client.id, fax_tag: "Group Testing Fax Tag") }
	let!(:user_group) {UserGroup.new(user_id: user.id, group_id: group.id)}

	describe "creating a UserGroup with valid input" do
		it "creates a UserGroup object with valid attributes" do
			expect(user_group).to be_valid
		end
	end

	describe "creating a UserGroup with invalid input" do
		it "is invalid when a user_id is absent or the wrong format" do
			user_group.user_id = nil
			expect(user_group).to be_invalid

			user_group.user_id = 11.1111
			expect(user_group).to be_invalid

			user_group.user_id = "one"
			expect(user_group).to be_invalid
		end

		it "is invalid when a group_id is absent or the wrong format" do
			user_group.group_id = nil
			expect(user_group).to be_invalid

			user_group.group_id = 4.4
			expect(user_group).to be_invalid

			user_group.group_id = "eleven"
			expect(user_group).to be_invalid
		end
	end
end
