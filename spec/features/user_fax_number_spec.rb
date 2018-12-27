require "rails_helper"

# This page bleeds heavily into the Organization tests
RSpec.feature "User Fax Number Pages", :type => :feature do
	let! (:admin) { User.create!( email: 'fake@phaxio.com', user_permission_attributes: { permission: UserPermission::ADMIN }) }
	let!(:org) { Organization.create(label: "Phaxio Test Company", admin_id: admin.id) }
	let!(:org2) { Organization.create(label: "Phaxio Test Company2", admin_id: admin.id) }
	let! (:manager) do 
		User.create!(email: 'manager@phaxio.com', user_permission_attributes: { permission: UserPermission::MANAGER }, organization_id: org.id, caller_id_number: '+17738675307')
	end
	let! (:manager2) do
		User.create!(email: 'manager2@phaxio.com', user_permission_attributes: { permission: UserPermission::MANAGER }, organization_id: org2.id, caller_id_number: '+17738675309')
	end
	let!(:user1) do 
		User.create(email: 'matt@phaxio.com', user_permission_attributes: { permission: UserPermission::USER }, caller_id_number: '+17738675309', organization_id: org.id)
	end
	let!(:user2) do 
		User.create(email: 'matt2@phaxio.com', user_permission_attributes: { permission: UserPermission::USER }, caller_id_number: '+17738675308', organization_id: org.id)
	end
	let!(:user3) do 
		User.create(email: 'matt3@phaxio.com', user_permission_attributes: { permission: UserPermission::USER }, caller_id_number: '+17738675309', organization_id: org.id)
	end
	let!(:fax_number1) { FaxNumber.create!(fax_number: '+17738675307', organization_id: org.id, org_switched_at: Time.now) }
	let!(:fax_number2) { FaxNumber.create!(fax_number: '+17738675308', organization_id: org.id, label: "OG Label", manager_label: "Manager-Set Label", org_switched_at: Time.now) }
	let!(:fax_number3) { FaxNumber.create!(fax_number: '+17738675309', org_switched_at: Time.now) }

	before(:each) do 
		org.update_attributes(manager_id: manager.id)
		org2.update_attributes(manager_id: manager2.id)
		org.fax_numbers << fax_number1
		org.fax_numbers << fax_number2
		org.users << user1
		org.users << user2
		user1.fax_numbers << fax_number1
		user1.fax_numbers << fax_number2
		user2.fax_numbers << fax_number1
	end

	describe "admin swapping organization phone numbers and editing its name" do
		it "allows the admin to add/remove fax numbers and edit the organization name" do
			login_as(admin)
			visit(organization_path(org))
			expect(page).to have_selector("h1", text: "Phaxio Test Company")
			click_link("Manage Phaxio Test Company Fax Numbers / Details")
			
			expect(page).to have_current_path("http://www.example.com/organizations/#{org.id}/edit")
			expect(page).to have_field("organization[label]")
			
			expect(page).to have_table("unlinked-numbers")
			within_table("unlinked-numbers") do
				expect(page).to have_field("fax_numbers[to_add][#{fax_number3.id}]")
			end

			expect(page).to have_table("linked-numbers")
			within_table("linked-numbers") do
				expect(page).to have_field("fax_numbers[to_remove][#{fax_number1.id}]")
				expect(page).to have_field("fax_numbers[to_remove][#{fax_number2.id}]")
			end

			# Remove(unlink) fax_number1, add(link) fax_number3
			check("fax_numbers[to_remove][#{fax_number1.id}]")
			check("fax_numbers[to_add][#{fax_number3.id}]")
			fill_in("organization[label]", with: "An Edited Label")
			click_button("Submit")

			expect(page).to have_current_path("http://www.example.com/organizations/#{org.id}")
			expect(page).to have_selector("h1", text: "An Edited Label")

			expect(page).to have_link("#{FaxNumber.format_pretty_fax_number(fax_number2.fax_number)}")
			expect(page).to have_link("#{FaxNumber.format_pretty_fax_number(fax_number3.fax_number)}")

			expect(page).to have_table("#{fax_number2.id}-users")
			within_table("#{fax_number2.id}-users") do
				expect(page).to have_text("Email")
				expect(page).to have_text("Caller ID")
				expect(page).to have_text("matt@phaxio.com")
				expect(page).to have_text("#{FaxNumber.format_pretty_fax_number('+17738675309')}")
				expect(page).not_to have_text("matt2@phaxio.com")
				expect(page).not_to have_text("#{FaxNumber.format_pretty_fax_number('+17738675308')}")
				expect(page).not_to have_text("matt3@phaxio.com") # this shouldn't be in the table
			end

			expect(page).to have_table("#{fax_number3.id}-users")
			within_table("#{fax_number3.id}-users") do # now fax_number3 obj
				expect(page).to have_text("Email")
				expect(page).to have_text("Caller ID")
				expect(page).not_to have_text("matt2@phaxio.com")
				expect(page).not_to have_text("#{FaxNumber.format_pretty_fax_number('+17738675308')}") # <-- matt2's caller_id_number
			end
		end
	end

	describe "Admin/Manager can add/remove fax numbers but not edit the organization name" do
		it "allows the Admin to add/remove fax numbers and edit the organization name" do
			login_as(admin)
			visit(organization_path(org))
			expect(page).to have_selector("h1", text: "Phaxio Test Company")
			expect(page).to have_table("#{fax_number2.id}-users")
			within_table("#{fax_number2.id}-users") do
				expect(page).to have_text("#{user1.email}")
			end

			click_link("Link / Unlink Users", href: "/user_fax_numbers/#{fax_number2.id}/edit")
			expect(page).to have_current_path(edit_user_fax_number_path(fax_number2))
			expect(page).to have_table('unlinked-users')
			within_table('unlinked-users') do
				expect(page).to have_text("#{manager.email}")
				expect(page).to have_text("#{user2.email}")
				expect(page).to have_text("#{user3.email}")
				check("#{manager.email}") # Link manager
			end

			expect(page).to have_table("linked-users")
			within_table("linked-users") do
				expect(page).to have_text("#{user1.email}")
				check("#{user1.email}") # Unlink user1 ("matt@phaxio.com")
			end
			click_button("Submit")

			expect(page).to have_current_path("http://www.example.com/organizations/#{org.id}")
			expect(page).to have_table("#{fax_number2.id}-users")
			within_table("#{fax_number2.id}-users") do
				expect(page).not_to have_text("#{user1.email}") # <-- Previously linked user
				expect(page).to have_text("#{manager.email}")	# <-- Newly linked user
			end

			click_link("#{FaxNumber.format_pretty_fax_number(fax_number2.fax_number)}")
			expect(page).to have_current_path("http://www.example.com/fax_numbers/#{fax_number2.id}/edit")
			#Edit fax_number functions are tested in fax_number_spec, not repeating them here
		end

		it "allows the Manager to add/remove fax numbers and edit the organization name" do
			login_as(manager)
			visit(organization_path(org))
			expect(page).to have_selector("h1", text: "Phaxio Test Company")
			expect(page).to have_table("#{fax_number2.id}-users")
			within_table("#{fax_number2.id}-users") do
				expect(page).to have_text("#{user1.email}")
			end

			click_link("Link / Unlink Users", href: "/user_fax_numbers/#{fax_number2.id}/edit")
			expect(page).to have_current_path(edit_user_fax_number_path(fax_number2))

			expect(page).to have_table('unlinked-users')
			within_table('unlinked-users') do
				expect(page).to have_text("#{manager.email}")
				expect(page).to have_text("#{user2.email}")
				expect(page).to have_text("#{user3.email}")
				check("#{manager.email}") # Link manager
			end

			expect(page).to have_table("linked-users")
			within_table("linked-users") do
				expect(page).to have_text("#{user1.email}")
				check("#{user1.email}") # Unlink user1 ("matt@phaxio.com")
			end
			click_button("Submit")

			expect(page).to have_current_path("http://www.example.com/organizations/#{org.id}")
			expect(page).to have_table("#{fax_number2.id}-users")
			within_table("#{fax_number2.id}-users") do
				expect(page).not_to have_text("#{user1.email}") # <-- Previously linked user
				expect(page).to have_text("#{manager.email}")	# <-- Newly linked user
			end

			click_link("#{FaxNumber.format_pretty_fax_number(fax_number2.fax_number)}")
			expect(page).to have_current_path("http://www.example.com/fax_numbers/#{fax_number2.id}/edit")
			#Edit fax_number functions are tested in fax_number_spec, not repeating them here
		end

		it "redirects the manager if they try to access a user_fax_number they are not in charge of" do
			login_as(manager2)
			visit(edit_user_fax_number_path(fax_number1))
			expect(page).to have_current_path("http://www.example.com/")
			expect(page).to have_text(ApplicationController::DENIED)
		end

		it "redirects a user if they try to access an organization they are not in charge of" do
			login_as(manager)
			visit(organization_path(org2))
			expect(page).to have_current_path("http://www.example.com/")
			expect(page).to have_text(ApplicationController::DENIED)
		end
	end
end