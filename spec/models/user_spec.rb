require 'rails_helper'

RSpec.describe User, type: :model do

  describe "creating a User with valid input" do
  	let!(:user) { User.new(type: :User, email: "test1@test.com", password: 'tomtom', client_id: 1) }

  	it "has valid attributes" do
  		expect(user).to be_valid
  	end

  	it "generates a fax_tag is none is supplied" do
  		user.save
  		expect(user.fax_tag).not_to be_nil
  	end

  	it "preserves a valid user-inputted fax tag" do
  		user.fax_tag = "Custom fax tag"
  		user.save
  		expect(user.fax_tag).to eq("Custom fax tag")
  	end

  	it "the 'type' attribute defaults to User" do
  		user2 = User.create!(email: "test2@test.com", password: 'passwordia', client_id: 1)
  		expect(user2.type).to eq("User")
  	end
  end

  describe "creating a User with invalid input" do
  	let!(:user) { User.new(email: "test3@test.com", password: 'hellohello', fax_tag: 'hello I am a fax tag', client_id: 1) }

  	it "does not persist if a email is longer than 60 characters" do
  		user.email = ("A" * 61)
  		expect(user).to be_invalid
  	end

  	it "does not persist if a email contains spaces" do
  		user.email = "One Space"
  		expect(user).to be_invalid
  		user.email = " A bunch of spaces in this name "
  		expect(user).to be_invalid
  		expect(user.errors[:email]).to include("email may not contain any spaces")
  	end

  	it "'client_id' attribute must be present and an integer if the User 'type' attribute is 'User'" do
  		user.client_id = nil
  		expect(user).to be_invalid
  		user.client_id = 'hello!'
  		expect(user).to be_invalid
  	end

  	it "does not persist if the fax_tag is longer than 60 characters" do
  		user.fax_tag = "A" * 61
  		expect(user).to be_invalid
  	end
  	
  	it "does not persist if a password is not present" do
  		user.password = nil
  		puts user.valid?
  		expect(user).to be_invalid
  	end

  	it "the 'type' boolean attribute cannot be updated and is read-only" do
  		user.save
  		user.update_attributes({type: :Admin, email: "Edited_email", password: "changed!"})
  		expect(user.reload.type).to eq("User")
  		expect(user.reload.email).to eq('Edited_email')
  		expect(user.reload.password).to eq('changed!')
  	end
  end
end