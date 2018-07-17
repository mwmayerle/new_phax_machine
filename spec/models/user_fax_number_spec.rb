require 'rails_helper'

RSpec.describe UserFaxNumber, type: :model do
	let! (:admin) do User.create!(
		email: 'fake@phaxio.com',
		user_permission_attributes: { permission: UserPermission::ADMIN }
	)
	end
	let!(:org) { Organization.create(label: "Phaxio Test Company", admin_id: admin.id) }
	let!(:user) do 
		User.create!(
			email: 'matt@phaxio.com',
			user_permission_attributes: { permission: UserPermission::USER },
			caller_id_number: '17738675309',
			organization_id: org.id
		)
	end
	let!(:fax_number1) { FaxNumber.create!(fax_number: '17738675309', organization_id: org.id, label: 'Fake Testing Number1') }
	let!(:user_fax_number) { UserFaxNumber.new(fax_number_id: fax_number1.id, user_id: user.id)}

	describe "with valid inputs" do
		it "is valid with valid inputs" do
			expect(user_fax_number).to be_valid
		end
	end

	describe "UserFaxNumber associations" do

		before(:each) { user_fax_number.save }

		it "belongs to a user" do
			assoc = UserFaxNumber.reflect_on_association(:user)
   		expect(assoc.macro).to eq(:belongs_to)
   		expect(user_fax_number.user).to eq(user)
		end

		it "belongs to fax_number" do
			assoc = UserFaxNumber.reflect_on_association(:fax_number)
   		expect(assoc.macro).to eq(:belongs_to)
   		expect(user_fax_number.fax_number).to eq(fax_number1)
		end
	end

	describe "with invalid inputs" do
		it "does not persist if the email_id or the fax_number_id attributes are not integers" do
			user_fax_number.user_id = "one"
			expect(user_fax_number).to be_invalid

			user_fax_number.user_id = 44.2345
			expect(user_fax_number).to be_invalid

			user_fax_number.fax_number_id = "potato"
			expect(user_fax_number).to be_invalid

			user_fax_number.fax_number_id = 1000001.4
			expect(user_fax_number).to be_invalid
		end

		it "does not persist if the email_id or fax_number_id attributes are absent" do
			user_fax_number.user_id = nil
			expect(user_fax_number).to be_invalid
			
			user_fax_number.user_id = user.id
			user_fax_number.fax_number_id = nil
			expect(user_fax_number).to be_invalid
		end
	end
end