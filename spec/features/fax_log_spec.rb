require "rails_helper"

RSpec.feature "Fax Logs", :type => :feature do
	let! (:admin) { User.create!( email: 'fake@phaxio.com', user_permission_attributes: { permission: UserPermission::ADMIN }) }
	let!(:org) { Organization.create!(label: "Phaxio Test Company", admin_id: admin.id, fax_numbers_purchasable: true) }
	let!(:org2) { Organization.create!(label: "Phaxio Test Company2", admin_id: admin.id) }
	let!(:org_deleted) { Organization.create!(label: "Deleted Test Company", admin_id: admin.id) }

	let! (:manager) do 
		User.create!(email: 'manager@phaxio.com', user_permission_attributes: { permission: UserPermission::MANAGER }, organization_id: org.id, caller_id_number: '+17738675307')
	end
	let! (:manager2) do
		User.create!(email: 'manager2@phaxio.com', user_permission_attributes: { permission: UserPermission::MANAGER }, organization_id: org2.id, caller_id_number: '+17738675309')
	end
	let! (:deleted_manager) do
		User.create!(email: 'deleted_manager@phaxio.com', user_permission_attributes: { permission: UserPermission::MANAGER }, organization_id: org_deleted.id, caller_id_number: '+17738679999')
	end
	let!(:user1) do 
		User.create!(email: 'matt@phaxio.com', user_permission_attributes: { permission: UserPermission::USER }, caller_id_number: '+17738675309', organization_id: org.id)
	end
	let!(:user2) do 
		User.create!(email: 'matt2@phaxio.com', user_permission_attributes: { permission: UserPermission::USER }, caller_id_number: '+17738675308', organization_id: org.id)
	end
	let!(:user3) do 
		User.create!(email: 'matt3@phaxio.com', user_permission_attributes: { permission: UserPermission::USER }, caller_id_number: '+17738675309', organization_id: org.id)
	end
	let!(:user4) do 
		User.create!(email: 'not_fully_registered@phaxio.com', caller_id_number: '+17738675366', organization_id: org.id)
	end
	let!(:user_deleted) do 
		User.create!(email: 'deleted_user@phaxio.com', caller_id_number: '+17738679999', organization_id: org_deleted.id)
	end
	let!(:fax_number1) { FaxNumber.create!(fax_number: '+17738675307', organization_id: org.id) }
	let!(:fax_number2) { FaxNumber.create!(fax_number: '+17738675308', organization_id: org.id, label: "OG Label", manager_label: "Manager-Set Label") }
	let!(:fax_number3) { FaxNumber.create!(fax_number: '+17738675309', organization_id: org2.id) }
	let!(:fax_number4) { FaxNumber.create!(fax_number: '+17738675310', organization_id: org2.id) }
	let!(:fax_number_deleted) { FaxNumber.create!(fax_number: '+17738679999', organization_id: org_deleted.id) }

	before(:each) do 
		org.update_attributes(manager_id: manager.id)
		org2.update_attributes(manager_id: manager2.id)
		org_deleted.update_attributes(manager_id: deleted_manager.id)
		org.users << user1
		org.users << user2
		org.users << user4
		org_deleted.users << user_deleted
		user1.fax_numbers << fax_number1
		user1.fax_numbers << fax_number2
		user2.fax_numbers << fax_number1
		user_deleted.fax_numbers << fax_number_deleted
		org.fax_numbers << fax_number1
		org.fax_numbers << fax_number2
		org_deleted.fax_numbers << fax_number_deleted
	end

	describe "org_deleted is soft deleted" do
		it "is soft-deleted" do
			# Deleting the organization this way is required because deleting through the terminal does not triggered the
			# ActiveRecord "before_destroy" callbacks.
			login_as(admin)
			visit(organizations_path)
			click_on("Delete Organization", match: :first)

			expect(Organization.all.with_deleted.map { |org| org.label }.include?("Deleted Test Company")).to be(true)
			expect(Organization.all.map { |org| org.label }.include?("Deleted Test Company")).to be(false)
			expect(User.all.with_deleted.map { |user| user.email }.include?("deleted_user@phaxio.com")).to be(true)
			expect(User.all.map { |user| user.email }.include?("deleted_user@phaxio.com")).to be(false)
		end
	end

	describe "visiting the fax log index the first time" do
		it "when logged in as an admin" do
			fax_nums_array = FaxNumber.all.map { |fax_num| FaxNumber.format_pretty_fax_number(fax_num.fax_number) }.push("All")
			login_as(admin)
			visit(fax_logs_path)
			expect(page).to have_select("fax_log[status]", options: ["All", "Success", "Failure", "In Progress", "Queued"])
			
			# Admin can see soft-deleted organizations
			expect(page).to have_select("fax_log[organization]", options: ["All", org.label, org2.label, org_deleted.label])

			expect(page).to have_select("fax_log[fax_number]", options: fax_nums_array)
			expect(page).to have_field("fax_log[start_time]")
			expect(page).to have_field("fax_log[end_time]")

			within_table("fax-log-table") do
				expect(page).to have_text("Path")
				expect(page).to have_text("Organization")
				expect(page).to have_text("Sent By")
				expect(page).to have_text("From Number")
				expect(page).to have_text("To Number")
				expect(page).to have_text("Status")
				expect(page).to have_text("Time")
				expect(page).to have_text("File")
			end
		end

		it "when logged in as a manager" do
			manager_fax_numbers = FaxNumber.where(organization_id: manager.organization.id)
			fax_nums_array = manager_fax_numbers.map { |fax_num| FaxNumber.format_pretty_fax_number(fax_num.fax_number) }.push("All")
			users_array = User.where(organization_id: manager.organization.id).select { |user| user.user_permission }.map { |user| user.email }.push("All")
			login_as(manager)
			visit(fax_logs_path)
			expect(page).not_to have_select("fax_log[organization]") # admin only

			expect(page).to have_select("fax_log[status]", options: ["All", "Success", "Failure", "In Progress", "Queued"])
			expect(page).to have_select("fax_log[fax_number]", options: fax_nums_array)
			expect(page).to have_select("fax_log[user]", options: users_array)
			expect(page).to have_field("fax_log[start_time]")
			expect(page).to have_field("fax_log[end_time]")

			within_table("fax-log-table") do
				expect(page).to have_text("Path")
				expect(page).to have_text("Sent By")
				expect(page).to have_text("From Number")
				expect(page).to have_text("To Number")
				expect(page).to have_text("Status")
				expect(page).to have_text("Time")
				expect(page).to have_text("File")
			end
		end

		it "when logged in as a generic user" do
			user1_fax_numbers = UserFaxNumber.where(user_id: user1.id).map { |user1_fax_num| user1_fax_num.fax_number }
			fax_nums_array = user1_fax_numbers.map { |fax_num| FaxNumber.format_pretty_fax_number(fax_num.fax_number) }.push("All")
			login_as(user1)
			visit(fax_logs_path)
			expect(page).not_to have_select("fax_log[user]") # manager only
			expect(page).not_to have_select("fax_log[organization]") # admin only

			expect(page).to have_select("fax_log[status]", options: ["All", "Success", "Failure", "In Progress", "Queued"])
			expect(page).to have_select("fax_log[fax_number]", options: fax_nums_array)
			expect(page).to have_field("fax_log[start_time]")
			expect(page).to have_field("fax_log[end_time]")

			within_table("fax-log-table") do
				expect(page).to have_text("Path")
				expect(page).to have_text("From Number")
				expect(page).to have_text("To Number")
				expect(page).to have_text("Status")
				expect(page).to have_text("Time")
				expect(page).to have_text("File")
			end
		end
	end
end