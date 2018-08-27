require 'rails_helper'

RSpec.describe UserPermission, type: :model do
	let! (:admin) do
		User.new(
			email: 'fake@phaxio.com',
			user_permission_attributes: { permission: UserPermission::ADMIN }
		)
	end
	let! (:manager) do
		User.new(
			email: 'manager@phaxio.com',
			user_permission_attributes: { permission: UserPermission::MANAGER }
		)
	end
	let!(:org) { Organization.create(label: "Phaxio Test Company", admin_id: admin.id, manager_id: manager.id) }

	let!(:user) do 
		User.new(
			email: 'matt@phaxio.com',
			user_permission_attributes: { permission: UserPermission::USER },
			caller_id_number: '17738675309',
			organization_id: org.id
		)
	end

	describe "admin" do
		it "only allows 1 admin to exist" do
			expect(admin).to be_valid
			admin.save
			admin2 = User.new(
				email: 'fakeadmin@phaxio.com',
				user_permission_attributes: { permission: UserPermission::ADMIN }
			)
			expect(admin2).to be_invalid
		end
	end
end