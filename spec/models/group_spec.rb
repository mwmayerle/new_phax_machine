# require 'rails_helper'

# RSpec.describe Group, type: :model do
# 	describe "creating a Group with valid input" do
# 		before(:each) do
# 			@group_leader = User.create!(email: 'tom@tom.com', password: 'tomtom')
# 			@group = Group.new(group_name: "Phaxio Accounting", display_name: "Accounting", group_leader_id: @group_leader.id)
# 		end

# 		it "is valid with valid attributes" do
# 			expect(@group).to be_valid
# 		end

# 		it "#ensure_display_name_exists custom validation method does not overwrite a user-provided display_name with the group_name" do
# 			@group.save
# 			expect(@group.display_name).to eq("Accounting")
# 		end
# 	end

# 	describe "creating a Group with invalid input" do
# 		before(:each) do
# 			@group_leader = User.create!(email: 'tom@tom.com', password: 'tomtom')
# 			@group = Group.new(group_name: "Phaxio Accounting", display_name: "Accounting", group_leader_id: @group_leader.id)
# 		end

# 		it "is invalid if a group_leader_id is not present or an invalid format" do
# 			@group.group_leader_id = nil
# 			expect(@group).to be_invalid
# 			@group.group_leader_id = "hello world!"
# 			expect(@group).to be_invalid
# 		end

# 		it "is invalid if a group_name is absent or too long" do
# 			@group.group_name = nil
# 			expect(@group).to be_invalid

# 			@group.group_name = "A" * 61
# 			expect(@group).to be_invalid
# 		end

# 		it "group_name attribute must be unique" do
# 			@group.save
# 			group2 = Group.new(group_name: "Phaxio Accounting", display_name: "Accounting v2.0", group_leader_id: @group_leader.id)
# 			expect(group2).to be_invalid
# 		end

# 		it "is invalid if a display_name is too long" do
# 			@group.group_name = "A" * 61
# 			expect(@group).to be_invalid
# 		end

# 		it "converts a blank display_name to the group_name if it is blank" do
# 			group2 = Group.new(group_name: "Phaxio Developers", group_leader_id: @group_leader.id)
# 			expect(group2).to be_valid
# 			expect(group2.display_name).to eq("Phaxio Developers")
# 		end

# 		it "#ensure_display_name_exists custom validation method 'plays nice' with other validations" do
# 			group2 = Group.new(group_leader_id: @group_leader.id)
# 			expect(group2).to be_invalid
# 			expect(group2.errors.full_messages).to include("Group name can't be blank")
# 		end

# 	end
# end
