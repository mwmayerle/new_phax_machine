# require 'rails_helper'

# RSpec.describe UserGroup, type: :model do
# 	describe "creating a UserGroup with valid input" do
# 		before(:each) do
# 			@group_leader = User.create!(is_group_leader: true, email: 'tim@tim.com', password: 'timtim')
# 			@user = User.create!(group_leader_id: @group_leader.id, email: 'tom@tom.com', password: 'tomtom')
# 			@group = Group.create!(group_name: "Phaxio Accounting", display_name: "Accounting", group_leader_id: @group_leader.id)
# 			@user_group = UserGroup.new(group_id: @group.id, user_id: @user.id)
# 		end

# 		it "creates a UserGroup object with valid attributes" do
# 			expect(@user_group).to be_valid
# 		end
# 	end

# 	describe "creating a UserGroup with invalid input" do
# 		before(:each) do
# 			@group_leader = User.create!(is_group_leader: true, email: 'tim@tim.com', password: 'timtim')
# 			@user = User.create!(email: 'tom@tom.com', password: 'tomtom', is_group_leader: true)
# 			@group = Group.create!(group_name: "Phaxio Accounting", display_name: "Accounting", group_leader_id: @group_leader.id)
# 			@user_group = UserGroup.new(group_id: @group.id, user_id: @user.id)
# 		end

# 		it "is invalid when a user_id is absent or the wrong format" do
# 			@user_group.user_id = nil
# 			expect(@user_group).to be_invalid

# 			@user_group.user_id = "one"
# 			expect(@user_group).to be_invalid
# 		end

# 		it "is invalid when a group_id is absent or the wrong format" do
# 			@user_group.group_id = nil
# 			expect(@user_group).to be_invalid

# 			@user_group.group_id = "eleven"
# 			expect(@user_group).to be_invalid
# 		end
# 	end
# end
