require "rails_helper"

RSpec.feature "User Pages", :type => :feature do
	let! (:admin) { User.create!( email: 'fake@phaxio.com', user_permission_attributes: { permission: UserPermission::ADMIN }) }
	let!(:org) { Organization.create!(label: "Phaxio Test Company", admin_id: admin.id) }
	let!(:org2) { Organization.create!(label: "Phaxio Test Company2", admin_id: admin.id) }
	let! (:manager) do 
		User.create!(email: 'manager@phaxio.com', user_permission_attributes: { permission: UserPermission::MANAGER }, organization_id: org.id, caller_id_number: '+17738675307')
	end
	let! (:manager2) do
		User.create!(email: 'manager2@phaxio.com', user_permission_attributes: { permission: UserPermission::MANAGER }, organization_id: org2.id, caller_id_number: '+17738675309')
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
	let!(:fax_number1) { FaxNumber.create!(fax_number: "+17738675307", organization_id: org.id) }
	let!(:fax_number2) { FaxNumber.create!(fax_number: "+17738675308", organization_id: org.id, label: "OG Label", manager_label: "Manager-Set Label") }
	let!(:fax_number3) { FaxNumber.create!(fax_number: "+17738675309") }

	before(:each) do 
		org.update_attributes(manager_id: manager.id)
		org2.update_attributes(manager_id: manager2.id)
		org.reload.fax_numbers << fax_number1
		org.reload.fax_numbers << fax_number2
		org.reload.users << user1
		org.reload.users << user2
		org.reload.users << user3
		org2.reload.fax_numbers << fax_number3
		user1.reload.fax_numbers << fax_number1
		user1.reload.fax_numbers << fax_number2
		user2.reload.fax_numbers << fax_number1
	end

	describe "editing an organization's users as an admin" do
		it "allows the admin and only the admin to access the 'org-index' page" do
			login_as(admin)
			visit(root_path)
			click_link('Users')
			expect(page).to have_current_path('http://www.example.com/org-users')
			expect(page).to have_link('Phaxio Test Company', href: users_path(organization_id: org.id))
			expect(page).to have_link('Phaxio Test Company2', href: users_path(organization_id: org2.id))

			click_link("#{org.label}", href: "/users?organization_id=#{org.id}")
			expect(page).to have_current_path("/users?organization_id=#{org.id}")
			expect(page).to have_field("user[email]")
			expect(page).to have_field("user[caller_id_number]")
			expect(page).to have_text("Indicates the user is #{org.label}'s manager")

			expect(page).to have_table("user-table")
			within_table("user-table") do
				expect(page).to have_text("Email Address")
				expect(page).to have_text("Caller ID")
				expect(page).to have_text("Active")
				expect(page).to have_text("matt@phaxio.com")
				expect(page).to have_text("#{FaxNumber.format_pretty_fax_number('+17738675309')}")
				expect(page).to have_text("matt2@phaxio.com")
				expect(page).to have_text("#{FaxNumber.format_pretty_fax_number('+17738675308')}")
				expect(page).to have_text("matt3@phaxio.com")
				expect(page).to have_text("#{FaxNumber.format_pretty_fax_number('+17738675309')}")
			end
		end
	end

	describe "user index permissions" do
		it "a generic user cannot access the 'org-index' page" do
			login_as(user1)
			visit('https://www.example.com/org-users')
			expect(page.current_url).to eq("https://www.example.com/")
			expect(page).to have_text(ApplicationController::DENIED)
		end

		it "a manager cannot access the 'org-index' page" do
			login_as(manager)
			visit('https://www.example.com/org-users')
			expect(page).to have_current_path("https://www.example.com/")
			expect(page).to have_text(ApplicationController::DENIED)
		end
	end

	describe "editing a user" do
		it "an admin can edit a user's email, caller_id_number, and permission simultaneously" do
			org.update_attributes(manager_id: nil)
			login_as(admin)
			visit(edit_user_path(user1.id))
			expect(page).to have_current_path(edit_user_path(user1.id))
			expect(page).to have_field("user[email]")
			expect(page).to have_select("user[caller_id_number]", options: ["(773) 867-5308 - Manager-Set Label", "(773) 867-5307"])
			expect(page).to have_select("user_permission[permission]", options: [UserPermission::MANAGER.titleize, UserPermission::USER.titleize])
			fill_in("user[email]", with: "phaxio@phaxio.com")
			select("(773) 867-5307", from: "user[caller_id_number]")
			select(UserPermission::MANAGER.titleize, from: "user_permission[permission]")
			click_button("Submit Changes")
			org.reload
			user1.reload
			expect(page).to have_text("User updated successfully")
			expect(page.current_url).to include("/users")
			expect(org.manager.id).to eq(user1.id)
			expect(user1.caller_id_number).to eq('+17738675307')
			expect(user1.user_permission.permission).to eq(UserPermission::MANAGER)
		end

		it "a manager can edit a user's caller_id_number and email. The permission field will not be visible" do
			login_as(manager)
			visit(edit_user_path(user1.id))
			expect(page).to have_current_path(edit_user_path(user1.id))
			expect(page).to have_field("user[email]")
			expect(page).to have_select("user[caller_id_number]", options: ["(773) 867-5308 - Manager-Set Label", "(773) 867-5307"])
			expect(page).not_to have_select("user_permission[permission]", options: [UserPermission::MANAGER.titleize, UserPermission::USER.titleize])
			fill_in("user[email]", with: "phaxio@phaxio.com")
			select("(773) 867-5307", from: "user[caller_id_number]")
			click_button("Submit Changes")
			user1.reload
			expect(page).to have_text("User updated successfully")
			expect(page.current_url).to include("/users")
			expect(user1.caller_id_number).to eq('+17738675307')
			expect(user1.user_permission.permission).to eq(UserPermission::USER)
		end

		it "a manager cannot access a user's edit page that is outside of their organization" do
			login_as(manager2)
			visit(edit_user_path(user1.id))
			expect(page).to have_current_path("http://www.example.com/")
			expect(page).to have_text(ApplicationController::DENIED)
		end
	end

	describe "creating a new user" do
		it "When invited from the organization index, the new manager has the selected fax number as their caller_id_number" do
			login_as(admin)
			manager.really_destroy!
			manager2.really_destroy!
			org2.really_destroy!
			visit(organizations_path)
			select("(773) 867-5308", from: "user[caller_id_number]")
			fill_in("user[email]", with: "waluigi@aol.com")
			click_button("Invite Manager")
			expect(page).to have_current_path(organizations_path)
			expect(page).to have_text("waluigi@aol.com has been invited.")
			new_user = User.last
			expect(new_user.caller_id_number).to eq("+17738675308")
			expect(new_user.email).to eq("waluigi@aol.com")
		end

		it "When invited from the organization index, a previously soft-deleted manager will be reinstated" do
			login_as(admin)
			manager.destroy
			visit(organizations_path)
			select("(773) 867-5308", from: "user[caller_id_number]")
			fill_in("user[email]", with: "#{manager.email}")
			click_button("Invite Manager")
			expect(page).to have_current_path(organizations_path)
			expect(page).to have_text("Access has been reinstated for #{manager.email}")
		end

		it "When invited from the organization index, a previously soft-deleted user who was not previously a manager will be reinstated as the manager" do
			login_as(admin)
			visit(edit_user_path(user1.id)) #used to manage org2
			click_on("Revoke Access")
			visit(edit_user_path(manager.id)) #used to manage org
			click_on("Revoke Access")
			visit(organizations_path)
			select("(773) 867-5308", from: "user[caller_id_number]", match: :first)
			fill_in("user[email]", with: "#{user1.email}", match: :first)
			click_button("Invite Manager")
			expect(page).to have_current_path(organizations_path)
			expect(page).to have_text("Access has been reinstated for #{user1.email}")
			expect(org.reload.manager.id).to eq(User.find_by!(email: "#{user1.email}").id)
		end

		it "When a manager that used to organize Group A is soft deleted and then invited to manage Group B, the reinstated manager will be in charge of Group B. All associations from the old group will be wiped out." do
			login_as(admin)
			user3.update_attributes(organization_id: org2.id)
			org2.users << user3
			visit(edit_user_path(manager.id)) #used to manage org
			click_on("Revoke Access")
			visit(edit_user_path(manager2.id)) #used to manage org2
			click_on("Revoke Access")
			visit(organizations_path)
			select("(773) 867-5308", from: "user[caller_id_number]", match: :first)
			fill_in("user[email]", with: "#{manager2.email}", match: :first)
			click_button("Invite Manager", match: :first)
			expect(page).to have_current_path(organizations_path)
			expect(page).to have_text("Access has been reinstated for #{manager2.email}")
			expect(org.reload.manager.id).to eq(User.find_by!(email: "#{manager2.email}").id)
			visit(organizations_path)
			select("(773) 867-5309", from: "user[caller_id_number]", match: :first)
			fill_in("user[email]", with: "#{manager.email}", match: :first)
			click_button("Invite Manager")
			expect(page).to have_current_path(organizations_path)
			expect(page).to have_text("Access has been reinstated for #{manager.email}")
			expect(org2.reload.manager.id).to eq(User.find_by!(email: "#{manager.email}").id)
			expect(manager.reload.users).to eq(org2.reload.users) #org2 generic users
			expect(manager2.reload.users).to eq(org.reload.users) #org generic users
		end
	end
end