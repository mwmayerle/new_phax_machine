require 'rails_helper'

RSpec.describe User, type: :model do

  describe "creating a User with valid input" do
    	let(:group_leader) { User.create!(email: 'tim@tim.com', password: 'timtim', is_group_leader: true) }
    	let(:user) { User.new(group_leader_id: @group_leader.id, email: 'tom@tom.com', password: 'tomtom') }
  	end

  	it "has valid attributes" do
  		expect(@user).to be_valid
  	end

  	it "generates a fax_tag is none is supplied" do
  		@user.save
  		expect(@user.fax_tag).not_to be_nil
  	end

  	it "preserves a valid user-inputted fax tag" do
  		@user.fax_tag = "Custom fax tag"
  		@user.save
  		expect(@user.fax_tag).to eq("Custom fax tag")
  	end

  	it "the 'is_admin' attribute defaults to false" do
  		expect(@user.is_admin).to be(false)
  	end

  	it "the 'is_group_leader' attribute defaults to false" do
  		expect(@user.is_group_leader).to be(false)
  	end
  end

  describe "creating a User with invalid input" do
  	before(:each) do
  		@admin = User.create!(email: 'tom@tom.com', password: 'tomtom', is_admin: true)
    	@group_leader = User.new(email: 'tim@tim.com', password: 'tomtom', is_group_leader: true)
    	@user = User.new(group_leader_id: @group_leader.id, email: 'tam@tam.com', password: 'tomtom')
  	end
  	# learned that @user.group_leader_id = '1' will persist...
  	it "does not persist if a group_leader_id is not a number" do
  		@user.group_leader_id = 'one'
  		expect(@user).to be_invalid
  	end

  	it "does not persist if a group_leader_email is not present" do
  		@user.email = nil
  		expect(@user).to be_invalid
  	end

  	it "does not persist if a user_email is longer than 60 characters" do
  		@user.email = ("A" * 60).concat('@aol.com')
  		expect(@user).to be_invalid
  	end

  	it "does not persist if the fax_tag is longer than 60 characters" do
  		@user.fax_tag = "A" * 61
  		expect(@user).to be_invalid
  	end
  	
  	it "does not persist if a password is not present" do
  		@user.password = nil
  		expect(@user).to be_invalid
  	end

  	it "does not persist if the group_leader already exists" do
  		@user.save
  		@user2 = User.new(group_leader_id: @group_leader.id, email: 'tom@tom.com', password: 'tomtom')
  		expect(@user2).to be_invalid
  	end

  	it "the 'is_admin' boolean attribute cannot be updated and is read-only" do
  		@admin.update_attributes({is_admin: false, email: 'edited_email@tom.com', password: "changed!"})
  		expect(@admin.reload.is_admin).to be(true)
  		expect(@admin.reload.email).to eq('edited_email@tom.com')
  		expect(@admin.reload.password).to eq('changed!')
  	end

  	it "the 'is_group_leader' boolean attribute cannot be updated and is read-only" do
  		@group_leader = User.create!(email: 'leader@leader.com', password: 'leader', is_group_leader: true)
  		@group_leader.update_attributes({email: 'edited_email@tom.com', password: "changed!", is_group_leader: false})
  		expect(@group_leader.reload.is_group_leader).to be(true)
  		expect(@group_leader.reload.email).to eq('edited_email@tom.com')
  		expect(@group_leader.reload.password).to eq('changed!')
  	end
  end
end