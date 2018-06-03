require 'rails_helper'

RSpec.describe SuperUser, type: :model do
  describe "creating a SuperUser with valid input" do
  	before(:each) do
    	@admin = Admin.create!(admin_email: 'tom@tom.com', password: 'tomtom')
    	@super_user = SuperUser.new(admin_id: @admin.id, super_user_email: 'tom@tom.com', password: 'tomtom')
  	end

  	it "has valid attributes" do
  		expect(@super_user).to be_valid
  	end

  	it "generates a fax_tag is none is supplied" do
  		@super_user.save
  		expect(@super_user.fax_tag).not_to be_nil
  	end

  	it "preserves a valid user-inputted fax tag" do
  		@super_user.fax_tag = "Custom fax tag"
  		@super_user.save
  		expect(@super_user.fax_tag).to eq("Custom fax tag")
  	end
  end

  describe "creating a SuperUser with invalid input" do
  	before(:each) do
    	@admin = Admin.create!(admin_email: 'tom@tom.com', password: 'tomtom')
    	@super_user = SuperUser.new(admin_id: @admin.id, super_user_email: 'tom@tom.com', password: 'tomtom')
  	end
  	# learned that @super_user.admin_id = '1' will persist...
  	it "does not persist if an admin_id is not present or is not a number" do
  		@super_user.admin_id = 'one'
  		expect(@super_user).to be_invalid

  		@super_user.admin_id = nil
  		expect(@super_user).to be_invalid
  	end

  	it "does not persist if a password is not present" do
  		@super_user.password = nil
  		expect(@super_user).to be_invalid
  	end

  	it "does not persist if a super_user_email is not present" do
  		@super_user.super_user_email = nil
  		expect(@super_user).to be_invalid
  	end

  	it "does not persist if a user_email is longer than 60 characters" do
  		@super_user.super_user_email = ("A" * 60).concat('@aol.com')
  		expect(@super_user).to be_invalid
  	end

  	it "does not persist if the fax_tag is longer than 60 characters" do
  		@super_user.fax_tag = "A" * 61
  		expect(@super_user).to be_invalid
  	end

  	it "does not persist if the super_user already exists" do
  		@super_user.save
  		@super_user2 = SuperUser.new(admin_id: @admin.id, super_user_email: 'tom@tom.com', password: 'tomtom')
  		expect(@super_user2).to be_invalid
  	end
  end
end
