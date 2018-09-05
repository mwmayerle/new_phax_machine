# require "rails_helper"
# # require "../fake_data/*"

# RSpec.describe FaxLog, type: :model do
# 	let! (:admin) { User.create!( email: 'mwmayerle@gmail.com', user_permission_attributes: { permission: UserPermission::ADMIN }) }
# 	let!(:org1) { Organization.create!(label: "Org One", admin_id: admin.id, fax_numbers_purchasable: true) }
# 	let!(:org2) { Organization.create!(label: "Org Two", admin_id: admin.id, fax_numbers_purchasable: false) }
# 	let!(:org3) { Organization.create!(label: "Org Three", admin_id: admin.id, fax_numbers_purchasable: true) }
# 	let!(:org4) { Organization.create!(label: "Org Four", admin_id: admin.id, fax_numbers_purchasable: false) }
# 	let!(:org5) { Organization.create!(label: "Org Five", admin_id: admin.id, fax_numbers_purchasable: true) }

# 	let! (:manager1) do 
# 		User.create!(email: 'org_one_manager@aol.com', user_permission_attributes: { permission: UserPermission::MANAGER }, organization_id: org1.id, caller_id_number: '+17738675307')
# 	end
# 	let! (:manager2) do 
# 		User.create!(email: 'org_two_manager@aol.com', user_permission_attributes: { permission: UserPermission::MANAGER }, organization_id: org2.id, caller_id_number: '+17738675307')
# 	end
# 	let! (:manager3) do 
# 		User.create!(email: 'org_three_manager@aol.com', user_permission_attributes: { permission: UserPermission::MANAGER }, organization_id: org3.id, caller_id_number: '+17738675307')
# 	end
# 	let! (:manager4) do 
# 		User.create!(email: 'org_four_manager@aol.com', user_permission_attributes: { permission: UserPermission::MANAGER }, organization_id: org4.id, caller_id_number: '+17738675307')
# 	end
# 	let! (:manager5) do 
# 		User.create!(email: 'org_five_manager@aol.com', user_permission_attributes: { permission: UserPermission::MANAGER }, organization_id: org5.id, caller_id_number: '+17738675307')
# 	end
# 	let!(:user1) do 
# 		User.create!(email: 'org_one_user@aol.com', user_permission_attributes: { permission: UserPermission::USER }, caller_id_number: '+17738675309', organization_id: org1.id)
# 	end
# 	let!(:user2) do 
# 		User.create!(email: 'org_two_user@aol.com', user_permission_attributes: { permission: UserPermission::USER }, caller_id_number: '+17738675309', organization_id: org2.id)
# 	end
# 		let!(:user3) do 
# 		User.create!(email: 'org_three_user@aol.com', user_permission_attributes: { permission: UserPermission::USER }, caller_id_number: '+17738675309', organization_id: org3.id)
# 	end
# 	let!(:user4) do 
# 		User.create!(email: 'org_four_user@aol.com', user_permission_attributes: { permission: UserPermission::USER }, caller_id_number: '+17738675309', organization_id: org4.id)
# 	end
# 	let!(:user5) do 
# 		User.create!(email: 'org_five_user@aol.com', user_permission_attributes: { permission: UserPermission::USER }, caller_id_number: '+17738675309', organization_id: org5.id)
# 	end

# 	let!(:fax_number1) { FaxNumber.create!(fax_number: '+17738675307', organization_id: org.id) }


# 	# before(:each) do
# 	# 	fax_number1.users <<
# 	# 	fax_number2.users <<
# 	# 	fax_number3.users <<
# 	# 	fax_number4.users <<
# 	# 	fax_number5.users <<
# 	# 	fax_number6.users <<
# 	# 	fax_number7.users <<
# 	# 	fax_number8.users <<
# 	# 	fax_number9.users <<
# 	# 	fax_number10.users <<
# 	# end

# 	describe "#build_options method when logged in as an admin" do
# 		it "when an admin is accessing the fax logs page for the first time, it defaults to the first 25 faxes within a week ago and the present" do
# 			filtered_params = {}
# 			options = FaxLog.build_options(admin, filtered_params)
# 			expect(options[:start_time]).to be_within(0.1).of(7.days.ago.to_datetime)
# 			expect(options[:end_time]).to be_within(0.1).of(DateTime.now)
# 			expect(options[:status]).to be_nil
# 			expect(options[:fax_number]).to be_nil
# 			expect(options[:tag]).to be_nil
# 		end

# 		it "when an admin is accessing the fax logs page and filtering for time" do
# 			filtered_params = {:start_time =>"08-01-2018", :end_time =>"08-24-2018"}
# 			options = FaxLog.build_options(admin, filtered_params)
# 			expect(options[:start_time]).to eq("Wed, 01 Aug 2018 00:00:00 +0000")
# 			expect(options[:end_time]).to eq("Fri, 24 Aug 2018 00:00:00 +0000")
# 		end
		
# 		it "when an admin is accessing the fax logs page and filtering for specific statuses it is nil if the admin wants 'all', otherwise it is the desired status" do
# 			%w(success failure queued inprogress all).each do |status|
# 				filtered_params = {:status => status}
# 				options = FaxLog.build_options(admin, filtered_params)
# 				status == "all" ? (expect(options[:status]).to be_nil) : (expect(options[:status]).to eq(status))
# 			end
# 		end

# 		it "when an admin is filtering for a fax_number, it is nil if the admin wants all and a specific fax number if it is not" do
# 			filtered_params = {:fax_number => fax_number1.fax_number} # +17738675307
# 			options = FaxLog.build_options(admin, filtered_params)
# 			expect(options[:fax_number]).to eq('+17738675307')

# 			filtered_params = {:fax_number => "all"} # +17738675307
# 			options = FaxLog.build_options(admin, filtered_params)
# 			expect(options[:fax_number]).to be_nil
# 		end

# 		it "when an admin is filtering for an organization, it is nil if the admin wants all and a specific organization if it is not" do
# 			filtered_params = { :organization => org.fax_tag }
# 			options = FaxLog.build_options(admin, filtered_params)
# 			expect(options[:tag]).to eq({ :sender_organization_fax_tag => org.fax_tag })

# 			filtered_params = {:organization => "all"}
# 			options = FaxLog.build_options(admin, filtered_params)
# 			expect(options[:tag]).to be_nil
# 		end

# 		# Currently searching by a specific user is a manager-only function, admins can't do it
# 		it "when an admin is filtering for a user, it is nil if the admin wants all and a specific organization if it is not" do
# 			filtered_params = { :user => user1.fax_tag }
# 			options = FaxLog.build_options(manager, filtered_params)
# 			expect(options[:tag]).to eq({ :sender_email_fax_tag => user1.fax_tag })

# 			filtered_params = {:user => "all"}
# 			options = FaxLog.build_options(manager, filtered_params)
# 			expect(options[:tag]).to be_nil
# 		end
# 	end

# 	# describe "#get_faxes for one organization" do
# 	# 	it "retrieves only data for one organization when filtering by that organization" do
# 	# 		@fax_numbers = ['+12064081185', '+12702166825']
# 	# 		org_one_fax_data = FaxLog.get_faxes(admin, options, @fax_numbers)
# 	# 	end
# 	# end

# 	describe "#get_faxes for one fax number" do
# 		it "retrieves only data related to the one fax number when filtering by that fax_number" do

# 		end
# 	end
# end