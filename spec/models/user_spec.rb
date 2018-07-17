require 'rails_helper'
# Please note that these model specs do not pass through the Devise controller
RSpec.describe User, type: :model do
	let! (:admin) do User.create!(
		email: 'fake@phaxio.com',
		user_permission_attributes: { permission: UserPermission::ADMIN }
	)
	end
	let!(:org) { Organization.create(label: "Phaxio Test Company", admin_id: admin.id) }
	let!(:user) do 
		User.new(
			email: 'matt@phaxio.com',
			user_permission_attributes: { permission: UserPermission::USER },
			caller_id_number: '17738675309',
			organization_id: org.id
		)
	end
	let!(:fax_number1) { FaxNumber.create!(fax_number: '17738675309', organization_id: org.id) }
	let!(:fax_number2) { FaxNumber.create!(fax_number: '12025550141', organization_id: org.id) }

  describe "creating a User with valid input" do
  	it "persists to the database with valid inputs" do
  		expect(user).to be_valid
  	end

  	it "creates a UserPermission object simultaneously" do
  		user.save
  		expect(user.user_permission.permission).to eq("user")
  		expect(UserPermission.all.count).to eq(2)
  	end

  	it "auto-generates a fax tag" do
  		expect(user.fax_tag).to be_nil
  		user.save
  		expect(user.fax_tag).not_to be_nil
  	end

  	it "auto-generates a temporary password" do
  		expect(user.password).to be_nil
  		user.save
  		expect(user.password).not_to be_nil
  	end
  end

  describe "creating a User with invalid input" do
  	it "email attribute must be more than #{User::USER_CHARACTER_LIMIT}" do
  		user.email = ("a" * 48).concat('@aol.com')
  		expect(user).to be_invalid
  	end

  	it "email attribute must be 5 or more characters" do
  		user.email = "@1.e"
  		expect(user).to be_invalid
  	end

  	it "is invalid if the email address is already in use" do
  		user.save
  		new_user = User.new(
			email: 'matt@phaxio.com',
			user_permission_attributes: { permission: UserPermission::USER },
			caller_id_number: '17738675309',
			organization_id: org.id
		)
  		expect(new_user).to be_invalid
  	end

  	it "is invalid if the email attribute is nil" do
			user.email = nil
			expect(user).to be_invalid
		end
  end

  describe "User model associations" do
  	before(:each) { user.save }

  	it "has one Manager object" do
  		assoc = User.reflect_on_association(:manager)
  		expect(assoc.macro).to eq(:has_one)
  	end

  	it "has one UserPermission object" do
  		assoc = User.reflect_on_association(:user_permission)
  		expect(assoc.macro).to eq(:has_one)
  	end

  	it "has many UserFaxNumber objects" do
  		user_fax_num1 = UserFaxNumber.create(fax_number_id: fax_number1.id, user_id: user.id)
  		user_fax_num2 = UserFaxNumber.create(fax_number_id: fax_number2.id, user_id: user.id)
  		assoc = User.reflect_on_association(:user_fax_numbers)
  		expect(assoc.macro).to eq(:has_many)
  		expect(user.user_fax_numbers).to eq([user_fax_num1, user_fax_num2])
  	end

  	 	it "has many FaxNumber objects" do
  		user.fax_numbers.push(fax_number1)
  		user.fax_numbers.push(fax_number2)
  		assoc = User.reflect_on_association(:fax_numbers)
  		expect(assoc.macro).to eq(:has_many)
  		expect(user.fax_numbers).to eq([fax_number1, fax_number2])
  	end

  	it "belongs to an Organization object" do
  		assoc = User.reflect_on_association(:organization)
  		expect(assoc.macro).to eq(:belongs_to)
  		expect(user.organization).to eq(org)
  	end
  end
end