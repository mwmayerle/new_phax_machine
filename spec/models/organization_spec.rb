require 'rails_helper'

RSpec.describe Organization, :type => :model do
	let! (:admin) do User.create!(
		email: 'fake@phaxio.com',
		user_permission_attributes: { permission: UserPermission::ADMIN }
	)
	end
	let!(:organization) { Organization.new(label: "Phaxio Test Company", admin_id: admin.id) }
	let!(:manager) do 
		User.create!(
			email: 'manager@phaxio.com',
			user_permission_attributes: { permission: UserPermission::MANAGER },
			caller_id_number: '17738675309',
			organization_id: organization.id
		)
	end
	let!(:user1) do 
		User.create!(
			email: 'matt@phaxio.com',
			user_permission_attributes: { permission: UserPermission::USER },
			caller_id_number: '17738675309',
			organization_id: organization.id
		)
	end
	let!(:user2) do 
		User.create!(
			email: 'helloworld@phaxio.com',
			user_permission_attributes: { permission: UserPermission::USER },
			caller_id_number: '17738675309',
			organization_id: organization.id
		)
	end
	let!(:fax_number1) {FaxNumber.create!(fax_number: '12025550134', label: "Fake1", organization_id: organization.id)}
	let!(:fax_number2) {FaxNumber.create!(fax_number: '12025550121', label: "Fake2", organization_id: organization.id)}
	let!(:fax_number3) {FaxNumber.create!(fax_number: '12025550167', label: "Fake3", organization_id: organization.id)}

	before(:each) { organization.update(manager_id: manager.id) }

	describe "creating an Organization with valid input" do
		it "is valid with valid inputs" do
			expect(organization).to be_valid
		end
	end

	describe "callbacks" do
		it "generates a fax tag if none is provided by the user" do
			organization.fax_tag = nil
			organization.save
			expect(organization.reload.fax_tag).not_to be_nil
		end
	end

	describe "assocations" do
		before(:each) do
			organization.save
			FaxNumber.all.each { |fax_number| organization.fax_numbers.push(fax_number) }
			user1.update_attributes(organization_id: organization.id)
			user2.update_attributes(organization_id: organization.id)
		end

		it "has many fax numbers" do
			assoc = Organization.reflect_on_association(:fax_numbers)
   		expect(assoc.macro).to eq(:has_many)
   		expect(organization.fax_numbers).to eq([fax_number1, fax_number2, fax_number3])
		end

		it "has many users" do
			assoc = Organization.reflect_on_association(:users)
   		expect(assoc.macro).to eq(:has_many)
   		expect(organization.users).to eq([user1, user2])
		end

		it "belongs to the admin" do
			assoc = Organization.reflect_on_association(:admin)
   		expect(assoc.macro).to eq(:belongs_to)
		end

		it "belongs to the manager" do
			assoc = Organization.reflect_on_association(:manager)
   		expect(assoc.macro).to eq(:belongs_to)
		end
	end

	describe "attempting to create an Organization with invalid input" do
		it "is invalid if the label is more than #{Organization::ORGANIZATION_CHARACTER_LIMIT} characters" do
			organization.label = "a" * (Organization::ORGANIZATION_CHARACTER_LIMIT + 1)
			expect(organization).not_to be_valid
		end

		it "is invalid if the fax_tag is more #{FaxTags::FAX_TAG_LIMIT} characters" do
			organization.fax_tag = "a" * (FaxTags::FAX_TAG_LIMIT + 1)
			expect(organization).to be_invalid
		end

		it "is invalid when the 'admin_id' and 'manager_id' attributes are not an integer" do
			organization.admin_id = :hello
			expect(organization).to be_invalid
			organization.manager_id = 'hello again!'
			expect(organization).to be_invalid
			organization.admin_id = 11.22
			expect(organization).to be_invalid
			organization.manager_id = '18'
			expect(organization).to be_invalid
		end

		it "is not possible to edit 'the admin_id' or 'fax_tag' attributes" do
			old_fax_tag = organization.fax_tag
			organization.update_attributes({ label: "An updated organization label", admin_id: manager.id, fax_tag: 'edited_fax_tag' })
			organization.reload
			expect(organization.admin_id).to eq(admin.id)
			expect(organization.label).to eq("An updated organization label")
			expect(organization.fax_tag).to eq(old_fax_tag)
		end
	end
end