require 'rails_helper'

RSpec.describe User, type: :model do
	let!(:admin) {User.create!(type: User::ADMIN, email: "mwmayerle@gmail.com", password: 'tomtom')}
	let!(:client) {Client.create!(admin_id: admin.id, client_label: "Client Controller Test Client")}
	let!(:client_manager) {User.create!(type: User::CLIENT_MANAGER, email: "matt@phaxio.com", client_id: client.id)}
	let!(:user1) {User.create!(email: "user1@gmail.com", client_id: client.id)}
	let!(:user2) {User.new(email: "user2@gmail.com", client_id: client.id)}
	let!(:fax_number1) {FaxNumber.create!(fax_number: '12025550134', fax_number_label: "Fake1", client_id: client.id)}
	let!(:fax_number2) {FaxNumber.create!(fax_number: '12025550121', fax_number_label: "Fake2", client_id: client.id)}
	let!(:user_email1) {UserEmail.create!(user_id: user1.id, email_address: 'user1@gmail.com', client_id: client.id)}
	let!(:user_email2) {UserEmail.create!(user_id: user2.id, email_address: 'user2@gmail.com', client_id: client.id)}
	let!(:fax_number_user_email1) {FaxNumberUserEmail.create!(user_email_id: user_email1.id, fax_number_id: fax_number1.id)}
	let!(:fax_number_user_email2) {FaxNumberUserEmail.create!(user_email_id: user_email1.id, fax_number_id: fax_number2.id)}
	before(:each) { client.update(client_manager_id: client_manager.id) }

  describe "creating a User with valid input" do
  	it "has valid attributes" do
  		expect(user2).to be_valid
  	end

  	it "generates a fax_tag" do
  		user2.save
  		expect(user2.fax_tag).not_to be_nil
  	end

  	it "the 'type' attribute defaults to User" do
  		user2 = User.create!(email: "test2@test.com", password: 'passwordia', client_id: 1)
  		expect(user2.type).to eq("User")
  	end

  	it "the 'type' and 'fax_tag' attributes cannot be updated and are read-only" do
  		old_fax_tag = user1.fax_tag
  		user1.update_attributes({type: User::ADMIN, email: "edited_email@email.biz", password: "changed!", fax_tag: "faxy-fax"})
  		user1.reload
  		expect(user1.type).to eq(User::USER)
  		expect(user1.email).to eq('edited_email@email.biz')
  		expect(user1.password).to eq('changed!')
  		expect(user1.fax_tag).to eq(old_fax_tag)
  	end
  end

  describe "User associations" do
  	it "has many fax numbers" do
			assoc = User.reflect_on_association(:fax_numbers)
   		expect(assoc.macro).to eq(:has_many)
   		expect(user1.fax_numbers).to eq([fax_number1, fax_number2])
		end

		it "belongs_to fax_number_user_email" do
			assoc = User.reflect_on_association(:fax_number_user_email)
   		expect(assoc.macro).to eq(:belongs_to)
   		expect(fax_number_user_email1.user).to eq(user1)
   		expect(fax_number_user_email2.user).to eq(user1)
		end

		it "has_one user_email" do
			assoc = User.reflect_on_association(:user_email)
   		expect(assoc.macro).to eq(:has_one)
   		expect(user1.user_email).to eq(user_email1)
		end

		it "has one the admin" do
			assoc = User.reflect_on_association(:admin)
   		expect(assoc.macro).to eq(:has_one)
   		expect(user1.admin).to eq(admin)
		end

		it "has one the user_manager" do
			assoc = User.reflect_on_association(:client_manager)
   		expect(assoc.macro).to eq(:has_one)
   		expect(user1.client_manager).to eq(client_manager)
		end
  end

  describe "creating a User with invalid input" do
  	it "does not persist if a email is longer than #{User::USER_CHARACTER_LIMIT} characters" do
  		user2.email = "A" * (User::USER_CHARACTER_LIMIT + 1)
  		expect(user2).to be_invalid
  	end

  	it "does not persist if a email contains spaces" do
  		user2.email = "One Space@test.com"
  		expect(user2).to be_invalid
  		user2.email = " A bunch of spaces in this name@aol.com"
  		expect(user2).to be_invalid
  		expect(user2.errors[:email]).to include("Email may not contain spaces")
  	end

  	it "'client_id' attribute must be present and an integer if the User 'type' attribute is #{User::USER}" do
  		user2.client_id = nil
  		expect(user2).to be_invalid

  		user2.client_id = 'hello!'
  		expect(user2).to be_invalid
  	end

  	it "does not persist if the fax_tag is longer than #{FaxTags::FAX_TAG_LIMIT} characters" do
  		user1.fax_tag = "A" * (FaxTags::FAX_TAG_LIMIT + 1)
  		expect(user1).to be_invalid
  	end
  	
  	it "generates a temporary password on create" do
  		user2.password = nil
  		user2.save
  		expect(user2.password).not_to be_nil
  	end

  	it "generates a reset password token" do
  		expect(user2.reset_password_token).to be_nil
  		user2.save
  		user2.reload
  		expect(user2.reset_password_token).not_to be_nil
  	end
  end
end