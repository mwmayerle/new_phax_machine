require 'rails_helper'

RSpec.describe Group, type: :model do
	let!(:admin) {User.create!(type: :Admin, email: 'testadmin@aol.com', password: 'testadmin')}
	let!(:client_manager) { User.create!(type: :ClientManager, email: 'test_manager@aol.com', password: "testmanager") }
	let!(:client) {Client.create!(admin_id: admin.id, client_manager_id: client_manager.id, client_label: "Client Model Test Client", fax_tag: "Test Fax Tag")}
	let!(:group) { Group.new(group_label: "Phaxio Accounting", display_label: "Accounting", client_id: client.id, fax_tag: "Group Testing Fax Tag") }

	describe "creating a Group with valid input" do
		it "is valid with valid attributes" do
			expect(group).to be_valid
		end

		it "generates a fax tag if none is provided by the user" do
			group.fax_tag = nil
			group.save
			expect(group.reload.fax_tag).not_to be_nil
		end

		it "#ensure_display_label_exists custom validation method does not overwrite a user-provided display_label with the group_label" do
			group.save
			expect(group.display_label).to eq("Accounting")
		end
	end

	describe "creating a Group with invalid input" do
		it "is invalid if a 'client_id' attribute is not present or an invalid format" do
			group.client_id = nil
			expect(group).to be_invalid
			group.client_id = "hello world!"
			expect(group).to be_invalid
			group.client_id = 11.111
			expect(group).to be_invalid
		end

		it "is invalid if a group_label is absent or too long" do
			group.group_label = nil
			expect(group).to be_invalid

			group.group_label = "A" * 61
			expect(group).to be_invalid
		end

		it "is invalid if a fax_tag is too long" do
			group.fax_tag = "A" * 61
			expect(group).to be_invalid
		end

		it "is invalid if a display_label is too long" do
			group.display_label = "A" * 61
			expect(group).to be_invalid
		end

		it "group_label attribute must be unique" do
			group.save
			group2 = Group.new(group_label: "Phaxio Accounting", display_label: "Accounting v2.0", client_id: client.id)
			expect(group2).to be_invalid
		end

		it "converts a blank display_label to the group_label if it is blank" do
			group2 = Group.new(group_label: "Phaxio Developers", client_id: client.id)
			expect(group2).to be_valid
			expect(group2.display_label).to eq("Phaxio Developers")
		end

		it "requires a fax tag to be unique" do
			group.save
			group2 = Group.new(fax_tag: group.fax_tag, group_label: "Phaxio Developers", client_id: client.id)
			expect(group2).to be_invalid
		end
	end
end
