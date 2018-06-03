require 'rails_helper'

RSpec.describe User, type: :model do

  describe "creating a User with valid input" do
  	before(:each) do
    	@super_user = SuperUser.create!(super_user_email: 'tom@tom.com', password: 'tomtom')
    	@user = User.new(super_user_id: @super_user.id, email: 'tom@tom.com', password: 'tomtom')
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
  end

  describe "creating a User with invalid input" do
  	before(:each) do
  		@admin = User.create!(email: 'tom@tom.com', password: 'tomtom', is_admin: true)
    	@super_user = SuperUser.new(super_user_email: 'tom@tom.com', password: 'tomtom')
    	@user = User.new(super_user_id: @super_user.id, email: 'tom@tom.com', password: 'tomtom')
  	end
  	# learned that @user.super_user_id = '1' will persist...
  	it "does not persist if a super_user_id is not a number" do
  		@user.super_user_id = 'one'
  		expect(@user).to be_invalid
  	end

  	it "does not persist if a super_user_email is not present" do
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

  	it "does not persist if the super_user already exists" do
  		@user.save
  		@user2 = User.new(super_user_id: @super_user.id, email: 'tom@tom.com', password: 'tomtom')
  		expect(@user2).to be_invalid
  	end

  	it "the 'is_admin' boolean attribute cannot be updated and is read-only" do
  		@admin.update_attributes({is_admin: false, email: 'edited_email@tom.com'})
  		expect(@admin.reload.is_admin).to be(true)
  		expect(@admin.reload.email).to eq('edited_email@tom.com')
  	end
  end
end