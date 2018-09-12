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
	let!(:initial_fake_data) { [] }
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

	describe "the #build_options method" do
		describe "the #add_start_time method" do
			it "#add_start_time sets the start_time in the options hash to an RFC3339 time based on user input" do
				filtered_params = { :start_time => "2018-09-02 8:58PM" }
				all_orgs = Organization.all
				options = FaxLog.build_options(admin, filtered_params, all_orgs, @users)
				expect(options[:start_time]).to eq("2018-09-02T20:58:00-05:00")

				options = FaxLog.build_options(manager1, filtered_params, org1, @users)
				expect(options[:start_time]).to eq("2018-09-02T20:58:00-05:00")

				options = FaxLog.build_options(user1, filtered_params, org1, @users)
				expect(options[:start_time]).to eq("2018-09-02T20:58:00-05:00")
			end

			it "#add_start_time defaults to 1 week ago if no start time is specified it is left blank (or it's the initial page load)" do
				filtered_params = { :fax_log=>{} }
				all_orgs = Organization.all
				options = FaxLog.build_options(admin, filtered_params, all_orgs, @users)
				expect(options[:start_time]).to eq((DateTime.now - 7).rfc3339)

				options = FaxLog.build_options(manager1, filtered_params, org1, @users)
				expect(options[:start_time]).to eq((DateTime.now - 7).rfc3339)

				options = FaxLog.build_options(user1, filtered_params, org1, @users)
				expect(options[:start_time]).to eq((DateTime.now - 7).rfc3339)
			end
		end

		describe "the #add_end_time method" do
			it "#add_end_time sets the end time in the options hash to an RFC3339 time based on user input" do
				filtered_params = { :end_time => "2018-09-02 8:58PM" }
				all_orgs = Organization.all
				options = FaxLog.build_options(admin, filtered_params, all_orgs, @users)
				expect(options[:end_time]).to eq("2018-09-02T20:58:00-05:00")

				all_orgs = Organization.all
				options = FaxLog.build_options(manager1, filtered_params, org1, @users)
				expect(options[:end_time]).to eq("2018-09-02T20:58:00-05:00")

				options = FaxLog.build_options(user1, filtered_params, org1, @users)
				expect(options[:end_time]).to eq("2018-09-02T20:58:00-05:00")
			end

			it "#add_end_time defaults to the current time if no end time is specified it is left blank (or it's the initial page load)" do
				filtered_params = { :fax_log=>{} }
				all_orgs = Organization.all
				options = FaxLog.build_options(admin, filtered_params, all_orgs, @users)
				expect(options[:end_time]).to eq(Time.now.to_datetime.rfc3339)

				options = FaxLog.build_options(manager1, filtered_params, org1, @users)
				expect(options[:end_time]).to eq(Time.now.to_datetime.rfc3339)

				options = FaxLog.build_options(user1, filtered_params, org1, @users)
				expect(options[:end_time]).to eq(Time.now.to_datetime.rfc3339)
			end
		end

		describe "the #set_fax_number_in_options method" do
			it "sets the fax_number to 'all' or 'all-linked' if a fax number besides 'all' or 'all-linked' is provided" do
				filtered_params = { :fax_number => "all" }
				all_orgs = Organization.all
				options = FaxLog.build_options(admin, filtered_params, all_orgs, @users)
				expect(options[:fax_number]).to eq("all")

				filtered_params = { :fax_number => "all-linked" }
				options = FaxLog.build_options(manager1, filtered_params, org1, @users)
				expect(options[:fax_number]).to eq("all-linked")
			end

			it "sets the fax_number to the specific desired fax_number if a fax_number is provided" do
				filtered_params = { :fax_number => "+17738675301" }
				all_orgs = Organization.all
				options = FaxLog.build_options(admin, filtered_params, all_orgs, @users)
				expect(options[:fax_number]).to eq("+17738675301")
			end
		end

		describe "#set_status_in_options method" do
			it "sets the status if the provided status is not 'all' " do
				statuses = %w[inprogress success failure queued all]
				statuses.each do |status|
					filtered_params = { :status => status }
					options = FaxLog.build_options(manager1, filtered_params, org1, @users)
					status == 'all' ? (expect(options[:status]).to be_nil) : (expect(options[:status]).to eq(status))
				end
			end
		end

		describe "#set_organization_in_options " do
			it "sets 'options[:tag] to the organization's fax tag if filtered_params[:organization] is not 'all'" do
				filtered_params = { :organization => org1.fax_tag }
				all_orgs = Organization.all
				options = FaxLog.build_options(admin, filtered_params, all_orgs, @users)
				expect(options[:tag]).to eq({ :sender_organization_fax_tag => org1.fax_tag })

				filtered_params = { :organization => 'all' }
				options = FaxLog.build_options(admin, filtered_params, all_orgs, @users)
				expect(options[:tag]).to be_nil
			end
		end

		describe "#set_tag_in_options_manager method when manager is logged in, it sets options[:tag] to a desired user's fax_tag" do
			it "sets 'options[:tag]' to the desired user if filtered_params[:user] is not 'all', 'all-linked', or nil. Logged in as manager" do
				@users = {} # this imitates "set_users", which is needed to create '@users' used in the method
				org1.users.each_with_index { |user_obj, index| FaxLog.create_users_hash(@users, user_obj, index) }

				filtered_params = { :user => user1.email }
				options = FaxLog.build_options(manager1, filtered_params, org1, @users)
				expect(options[:tag]).to eq({ :sender_email_fax_tag => user1.fax_tag })

				filtered_params = { :user => nil }
				options = FaxLog.build_options(manager1, filtered_params, org1, @users)
				expect(options[:tag]).to eq({ :sender_organization_fax_tag => org1.fax_tag })

				filtered_params = { :user => 'all-linked' }
				options = FaxLog.build_options(manager1, filtered_params, org1, @users)
				expect(options[:tag]).to eq({ :sender_organization_fax_tag => org1.fax_tag })

				filtered_params = { :user => 'all' }
				options = FaxLog.build_options(manager1, filtered_params, org1, @users)
				expect(options[:tag]).to eq({ :sender_organization_fax_tag => org1.fax_tag })
			end
		end

		describe "#set_tag_in_options_user method" do
			it "#set_tag_in_options_user sets the 'options[:tag]' to the current_user if a generic user is logged in" do
				@users = {} # again this imitates "set_users"
				[user1].each_with_index { |user_obj, index| FaxLog.create_users_hash(@users, user_obj, index) }

				filtered_params = { :user => user1.email }
				options = FaxLog.build_options(user1, filtered_params, org1, @users)
				expect(options[:tag]).to eq({ :sender_email_fax_tag => user1.fax_tag })
			end
		end
	end
#### Methods and arguments below in FakeApiResponse module included above ####

# build_successful_sent_fax_objects(id, quantity, caller_id_number, recipient_number, organization_object, user_object, fake_data = [])
# build_failed_sent_fax_objects(id, quantity, caller_id_number, recipient_number, organization_object, user_object, fake_data = [])
# build_successful_received_fax_objects(id, quantity, from_number, to_number, fake_data = [])
# build_failed_received_fax_objects(id, quantity, from_number, to_number, organization_object, user_object, fake_data = [])

# This module is used to mimic the result of the multiple "list_faxes" (FaxLog.get_faxes) API get requests that are combined and 
#   then filtered, resulting in nested arrays of fax objects that are then pushed into a new single array and sorted by date in 
#   the "sort_faxes" FaxLog method.

# 'fake_data' variable is a previously defined empty array
	describe "#format_faxes method as a manager" do
		before(:each) do
			# mimic set_organization controller method
			@organization = org1
			# mimic set_fax_numbers controller method
			@fax_numbers = {}
			org1.fax_numbers.each { |fax_number_obj| FaxLog.create_fax_nums_hash(@fax_numbers, fax_number_obj) }
			# mimic set_users controller method
			@users = {}
			criteria_array = org1.users.select { |user| user.user_permission }
			criteria_array.each_with_index { |user_obj, index| FaxLog.create_users_hash(@users, user_obj, index) }
		end

		# org1 has 3 fax numbers
		it "returns only faxes sent/received by a specific organization when requested (manager requesting their own organization's faxes)" do
			statuses = %w[inprogress success failure queued all]

			# 10 successful faxes sent from org1 using each fax_number, (sum of 30)
			initial_fake_data << build_successful_sent_fax_objects(111111, 4, manager1.caller_id_number, org1.fax_numbers.first.fax_number, org1, manager1)
			initial_fake_data << build_successful_sent_fax_objects(111121, 4, manager1.caller_id_number, org1.fax_numbers.second.fax_number, org1, manager1)
			initial_fake_data << build_successful_sent_fax_objects(111131, 4, manager1.caller_id_number, org1.fax_numbers.third.fax_number, org1, manager1)

			# 2 failed faxes from org1 using each number
			initial_fake_data << build_failed_sent_fax_objects(111143, 2,  manager1.caller_id_number, org1.fax_numbers.first.fax_number, org1, manager1)
			initial_fake_data << build_failed_sent_fax_objects(111145, 2,  manager1.caller_id_number, org1.fax_numbers.second.fax_number, org1, manager1)
			initial_fake_data << build_failed_sent_fax_objects(111147, 2,  manager1.caller_id_number, org1.fax_numbers.third.fax_number, org1, manager1)

			# 10 successful faxes received by each number within org1 from '+12223334444' (sum 30)
			initial_fake_data << build_successful_received_fax_objects(111151, 4, '+12223334444', org1.fax_numbers.first.fax_number)
			initial_fake_data << build_successful_received_fax_objects(111161, 4, '+12223334444', org1.fax_numbers.second.fax_number)
			initial_fake_data << build_successful_received_fax_objects(111171, 4, '+12223334444', org1.fax_numbers.third.fax_number)

			# 2 failed received faxes to each number in org1 sent from '+12223334444'
			initial_fake_data << build_failed_received_fax_objects(111183, 2, '+12223334444', org1.fax_numbers.first.fax_number)
			initial_fake_data << build_failed_received_fax_objects(111185, 2, '+12223334444', org1.fax_numbers.second.fax_number)
			initial_fake_data << build_failed_received_fax_objects(111187, 2, '+12223334444', org1.fax_numbers.third.fax_number)

			formatted_faxes = FaxLog.format_faxes(manager1, initial_fake_data, @organization, @fax_numbers, @users)

			expect(formatted_faxes.class).to eq(Hash)
			expect(formatted_faxes.keys.length).to eq(36)

			formatted_faxes.each do |fax_id_key, fax_obj_info_value|
				expect(fax_obj_info_value['status']).to eq("Failure").or eq("Success")
				expect(fax_obj_info_value['direction']).to eq("Sent").or eq("Received")
			end
		end

		it "the 'recipients' portion is set to 'multiple' if there is more than 1 recipient" do
			initial_fake_data << build_successful_sent_fax_objects(111111, 1, manager1.caller_id_number, org1.fax_numbers.first.fax_number, org1, manager1)
			# force the data to have multiple recipients
			initial_fake_data[0][0]['recipients'] << {"phone_number"=>"+17738679999", "status"=>"success", "retry_count"=>0, "completed_at"=>(DateTime.now + 8), "bitrate"=>9600, "resolution"=>8040, "error_type"=>nil, "error_id"=>nil, "error_message"=>nil}
			formatted_faxes = FaxLog.format_faxes(manager1, initial_fake_data, @organization, @fax_numbers, @users)
			expect(formatted_faxes[111111]['to_number']).to eq("Multiple")
		end

		it "filters only data for a specific user when asked" do
			filtered_params = { :user => user3.email }
			@users = {0=>{"email"=>"org_one_user3@aol.com", "caller_id_number"=>user3.caller_id_number, "user_created_at"=> (DateTime.now + 7), "fax_tag"=>user3.fax_tag}}

			tag_data = []
			tag_data << build_successful_sent_fax_objects(111111, 1, fax_number3.fax_number, org2.fax_numbers.first.fax_number, org1, manager1)
			tag_data << build_successful_sent_fax_objects(111112, 1, manager1.caller_id_number, org1.fax_numbers.first.fax_number, org1, manager1)
			tag_data.flatten!

			options = FaxLog.build_options(manager1, filtered_params, @organization, @users)
			filtered_data = FaxLog.filter_faxes_by_user(options, tag_data, @users)
			expect(filtered_data.length).to eq(1)
			expect(filtered_data[0]["id"]).to eq(111111)
		end
	end

	describe "format_faxes and associated methods when an admin is logged in" do
		before(:each) do
			@organizations = {}
			Organization.all.each { |organization_obj| FaxLog.create_orgs_hash(@organizations, organization_obj) }
			@fax_numbers = {}
			numbers_from_db = FaxNumber.where.not(organization_id: nil)
			numbers_from_db.each { |fax_number_obj| FaxLog.create_fax_nums_hash(@fax_numbers, fax_number_obj) }
			@users = {}
			criteria_array = User.includes([:organization, :user_permission]).all.select { |user| user.user_permission && user.organization }
			criteria_array.each_with_index { |user_obj, index| FaxLog.create_users_hash_admin(@users, user_obj, index) }
		end

		it "an organization label is not used if a fax pre-dates the creation of the organization" do
			initial_fake_data << build_successful_sent_fax_objects(111111, 2, manager1.caller_id_number, org1.fax_numbers.first.fax_number, org1, manager1)
			initial_fake_data << build_successful_sent_fax_objects(111113, 1, manager1.caller_id_number, org1.fax_numbers.first.fax_number, org1, manager1)

			# set date to pre-date the organization for first and last fake fax object
			initial_fake_data[0][0]['created_at'] = (org1.created_at - 7)
			initial_fake_data[1][0]['created_at'] = (org1.created_at - 7) # remember it's an array of arrays prior to the format_faxes method
			formatted_faxes = FaxLog.format_faxes(admin, initial_fake_data, @organizations, @fax_numbers, @users)
			expect(formatted_faxes[111111]['organization']).to be_nil
			expect(formatted_faxes[111113]['organization']).to be_nil
			expect(formatted_faxes[111112]['organization']).to eq('Org One')
		end

		it "filters only data for a specific fax number when asked" do
			# +17738675301 is manager1's caller_id_number
			@fax_numbers.each { |fax_num_key, fax_num_value| @fax_numbers.delete(fax_num_key) if fax_num_key != "+17738675301"}
			tag_data = []

			tag_data << build_successful_sent_fax_objects(111111, 1, manager2.caller_id_number, org2.fax_numbers.first.fax_number, org2, manager2)
			tag_data << build_successful_sent_fax_objects(111112, 1, manager1.caller_id_number, org1.fax_numbers.first.fax_number, org1, manager1)
			tag_data.flatten!

			results = FaxLog.fax_obj_recipient_data_in_fax_numbers?(tag_data[0], @fax_numbers)	
			expect(results).to be(false)
			results = FaxLog.fax_obj_recipient_data_in_fax_numbers?(tag_data[1], @fax_numbers)
			expect(results).to be(true)

			results = FaxLog.sent_caller_id_in_fax_numbers?(tag_data[0], @fax_numbers)
			expect(results).to be(false)
			results = FaxLog.sent_caller_id_in_fax_numbers?(tag_data[1], @fax_numbers)
			expect(results).to be(true)

			results = FaxLog.filter_for_desired_fax_number_data(tag_data, @fax_numbers)
			expect(results.length).to be(1)
			expect(results.pop["id"]).to eq(111112)
		end
	end
end