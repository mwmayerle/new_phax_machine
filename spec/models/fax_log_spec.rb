require 'rails_helper'
require 'date'
require 'fake_api_response'

RSpec.describe FaxLog, type: :model do
	include FakeApiResponse

	let! (:admin) { User.create!( email: 'mwmayerle@gmail.com', user_permission_attributes: { permission: UserPermission::ADMIN }) }
	let!(:org1) { Organization.create!(label: "Org One", admin_id: admin.id, fax_numbers_purchasable: true) }
	let!(:org2) { Organization.create!(label: "Org Two", admin_id: admin.id, fax_numbers_purchasable: false) }

	let!(:fax_number1) { FaxNumber.create!(fax_number: '+17738675301', organization_id: org1.id) }
	let!(:fax_number2) { FaxNumber.create!(fax_number: '+17738675302', organization_id: org1.id) }
	let!(:fax_number3) { FaxNumber.create!(fax_number: '+17738675303', organization_id: org1.id) }
	let!(:fax_number4) { FaxNumber.create!(fax_number: '+17738675344', organization_id: org2.id) }
	let!(:fax_number5) { FaxNumber.create!(fax_number: '+17738675355', organization_id: org2.id) }
	let!(:fax_number6) { FaxNumber.create!(fax_number: '+17738675366', organization_id: org2.id) }

	let! (:manager1) do 
		User.create!(email: 'org_one_manager@aol.com', user_permission_attributes: { permission: UserPermission::MANAGER }, organization_id: org1.id, caller_id_number: fax_number1.fax_number)
	end
	let! (:manager2) do 
		User.create!(email: 'org_two_manager@aol.com', user_permission_attributes: { permission: UserPermission::MANAGER }, organization_id: org2.id, caller_id_number: fax_number4.fax_number)
	end

	let!(:user1) do 
		User.create!(email: 'org_one_user1@aol.com', user_permission_attributes: { permission: UserPermission::USER }, caller_id_number: fax_number1.fax_number, organization_id: org1.id)
	end
	let!(:user2) do 
		User.create!(email: 'org_one_user2@aol.com', user_permission_attributes: { permission: UserPermission::USER }, caller_id_number: fax_number2.fax_number, organization_id: org1.id)
	end
	let!(:user3) do 
		User.create!(email: 'org_one_user3@aol.com', user_permission_attributes: { permission: UserPermission::USER }, caller_id_number: fax_number3.fax_number, organization_id: org1.id)
	end

	let!(:fake_data) { [] }
	let!(:raw_fake_data) { [] }

	before(:each) do
		fax_number1.users << user1
		fax_number2.users << user2
		fax_number3.users << user3
		fax_number1.users << manager1
		fax_number2.users << manager2

		org1.update_attributes(manager_id: manager1.id)
		org2.update_attributes(manager_id: manager2.id)
	end # before(:each)

	#### Methods and arguments below in FakeApiResponse module included above ####
	# build_successful_sent_fax_objects(id, quantity, organization_object, recipient_number, fake_data = [])
	# build_failed_sent_fax_objects(id, quantity, caller_id_number, recipient_number, organization_object, user_object, fake_data = [])
	# build_successful_received_fax_objects(id, quantity, from_number, to_number, fake_data = [])
	# build_failed_received_fax_objects(id, quantity, from_number, to_number, organization_object, user_object, fake_data = [])

	it "prints hello world" do
		p testing = build_failed_received_fax_objects(99, 1, "+12242136849", "+13332224444", org1, user1, fake_data = [])
	end
end
