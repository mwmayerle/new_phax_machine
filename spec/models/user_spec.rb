require 'rails_helper'

RSpec.describe User, type: :model do

  describe "creating a User with valid input" do
  	let!(:user) { User.new(type: :User, email: 'tom@tom.com', password: 'tomtom', client_id: 1) }

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
  		user2 = User.create!(email: 'user2@aol.com', password: 'passwordia')
  		expect(user2.type).to eq("User")
  	end
  end

  describe "creating a User with invalid input" do
  	let!(:user) { User.new(email: 'hello@aol.com', password: 'hellohello', fax_tag: 'hello I am a fax tag') }

  	it "does not persist if a user_email is longer than 60 characters" do
  		user.email = ("A" * 60).concat('@aol.com')
  		expect(user).to be_invalid
  	end

  	it "does not persist if the fax_tag is longer than 60 characters" do
  		user.fax_tag = "A" * 61
  		expect(user).to be_invalid
  	end
  	
  	it "does not persist if a password is not present" do
  		user.password = nil
  		expect(user).to be_invalid
  	end

  	it "the 'type' boolean attribute cannot be updated and is read-only" do
  		user.save
  		user.update_attributes({type: :Admin, email: 'edited_email@tom.com', password: "changed!"})
  		expect(user.reload.type).to eq("User")
  		expect(user.reload.email).to eq('edited_email@tom.com')
  		expect(user.reload.password).to eq('changed!')
  	end
  end
end