require 'rails_helper'
require 'date'
require 'fake_api_response'

# I've faked timestamps and fax numbers, but the data in "expect" methods is real data

RSpec.describe FakeApiResponse, type: :model do
	include FakeApiResponse

	let!(:admin) { User.create!( email: 'mwmayerle@gmail.com', user_permission_attributes: { permission: UserPermission::ADMIN }) }
	let!(:org1) { Organization.create!(label: "Org One", admin_id: admin.id, fax_numbers_purchasable: true) }
	let! (:manager1) do 
		User.create!(email: 'org_one_manager@aol.com', user_permission_attributes: { permission: UserPermission::MANAGER }, organization_id: org1.id, caller_id_number: '+1989555121')
	end

	it "#build_successful_sent_fax_objects imitates what the Phaxio gem returns" do
		result = build_successful_sent_fax_objects(81825292, 1, '+19895551999', '+15315557999', org1, manager1).pop
		expect(result[:id]).to eq(81825292)
		expect(result[:direction]).to eq("sent")
		expect(result[:num_pages]).to eq(1)
		expect(result[:status]).to eq("success")
		expect(result[:is_test]).to be(false)
		expect(result[:caller_id]).to eq("+19895551999")
		expect(result[:from_number]).to be_nil
		expect(result[:cost]).to eq(7)
		expect(result[:tags]).to eq({sender_organization_fax_tag: org1.fax_tag, sender_email_fax_tag: manager1.fax_tag})
		expect(result[:recipients][0][:phone_number]).to eq('+15315557999')
		expect(result[:recipients][0][:status]).to eq('success')
		expect(result[:recipients][0][:retry_count]).to eq(0)
		expect(result[:recipients][0][:bitrate]).to eq(9600)
		expect(result[:recipients][0][:resolution]).to eq(8040)
		expect(result[:recipients][0][:error_type]).to be_nil
		expect(result[:recipients][0][:error_id]).to be_nil
		expect(result[:recipients][0][:error_message]).to be_nil
		expect(result[:error_type]).to be_nil
		expect(result[:error_id]).to be_nil
		expect(result[:error_message]).to be_nil
	end

	it "#build_successful_received_fax_objects imitates what the Phaxio gem returns" do
		result = build_successful_received_fax_objects(82997626, 1, '+19895551999', '+15315557999').pop
		expect(result[:id]).to eq(82997626)
		expect(result[:direction]).to eq("received")
		expect(result[:num_pages]).to eq(1)
		expect(result[:status]).to eq("success")
		expect(result[:is_test]).to be(false)
		expect(result[:caller_id]).to be_nil
		expect(result[:to_number]).to eq('+15315557999')
		expect(result[:from_number]).to eq('+19895551999')
		expect(result[:cost]).to eq(7)
		expect(result[:tags]).to eq({})
		expect(result[:error_type]).to be_nil
		expect(result[:error_id]).to be_nil
		expect(result[:error_message]).to be_nil
	end

	it "#build_failed_received_fax_objects imitates what the Phaxio gem returns" do
		result = build_failed_received_fax_objects(82410268, 1, '+19895551999', '+15315557999').pop
		expect(result[:id]).to eq(82410268)
		expect(result[:direction]).to eq("received")
		expect(result[:num_pages]).to eq(0)
		expect(result[:status]).to eq("failure")
		expect(result[:is_test]).to be(false)
		expect(result[:caller_id]).to be_nil
		expect(result[:to_number]).to eq('+15315557999')
		expect(result[:from_number]).to eq('+19895551999')
		expect(result[:recipients]).to be_nil
		expect(result[:cost]).to eq(0)
		expect(result[:tags]).to eq({})
		expect(result[:error_type]).not_to be_nil
		expect(result[:error_id]).not_to be_nil
		expect(result[:error_message]).not_to be_nil
	end

	it "#build_failed_sent_fax_objects imitates what the Phaxio gem returns" do
		result = build_failed_sent_fax_objects(81807216, 1, '+19895551999', '+15315557999', org1, manager1).pop
		expect(result[:id]).to eq(81807216)
		expect(result[:direction]).to eq("sent")
		expect(result[:num_pages]).to eq(1)
		expect(result[:status]).to eq("failure")
		expect(result[:is_test]).to be(false)
		expect(result[:caller_id]).to eq("+19895551999")
		expect(result[:from_number]).to be_nil
		expect(result[:to_number]).to be_nil
		expect(result[:cost]).to eq(0)
		expect(result[:tags]).to eq({sender_organization_fax_tag: org1.fax_tag, sender_email_fax_tag: manager1.fax_tag})
		expect(result[:recipients][0][:phone_number]).to eq('+15315557999')
		expect(result[:recipients][0][:status]).to eq('failure')
		expect(result[:recipients][0][:retry_count]).to eq(0)
		expect(result[:recipients][0][:bitrate]).to be_nil
		expect(result[:recipients][0][:resolution]).to be_nil
		expect(result[:recipients][0][:error_type]).not_to be_nil
		expect(result[:recipients][0][:error_id]).not_to be_nil
		expect(result[:recipients][0][:error_message]).not_to be_nil
		expect(result[:error_type]).to be_nil
		expect(result[:error_id]).to be_nil
		expect(result[:error_message]).to be_nil
	end
end