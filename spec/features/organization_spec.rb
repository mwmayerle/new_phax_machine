require "rails_helper"

RSpec.feature "Organization Pages", :type => :feature do
	let! (:admin) { User.create!( email: 'fake@phaxio.com', user_permission_attributes: { permission: UserPermission::ADMIN }) }
	let!(:org) { Organization.create!(label: "Phaxio Test Company", admin_id: admin.id, fax_numbers_purchasable: true) }
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
	let!(:fax_number1) { FaxNumber.create!(fax_number: '+17738675307', organization_id: org.id) }
	let!(:fax_number2) { FaxNumber.create!(fax_number: '+17738675308', organization_id: org.id, label: "OG Label", manager_label: "Manager-Set Label") }
	let!(:fax_number3) { FaxNumber.create!(fax_number: '+17738675309') }

	before(:each) do 
		org.update_attributes(manager_id: manager.id)
		org2.update_attributes(manager_id: manager2.id)
		org.users << user1
		org.users << user2
		user1.fax_numbers << fax_number1
		user1.fax_numbers << fax_number2
		user2.fax_numbers << fax_number1
		org.fax_numbers << fax_number1
		org.fax_numbers << fax_number2
	end

	describe "organization index when logged in as an admin" do
		it "redirects to the user_sign_in page if no user is logged in" do
			visit(organizations_path)
			expect(page).to have_button("Log In")
			expect(page).to have_field("user[email]")
			expect(page).to have_field("user[password]")
			expect(page).to have_current_path("http://www.example.com/users/sign_in")
			expect(page).to have_link('Log In', href: new_user_session_path)
		end

		it "allows the admin to access the organization index route" do
			login_as(admin)
			visit(organizations_path)
			expect(page).to have_current_path("http://www.example.com/organizations")

			# navbar links
			expect(page).to have_link('Add New Organization') # This appears as a button
			expect(page).to have_link('Organizations', href: organizations_path)
			expect(page).to have_link('Fax Numbers', href: fax_numbers_path)
			expect(page).to have_link('Edit Profile')
			expect(page).to have_link('Users', href: '/org-users')
			expect(page).to have_link('Fax Logs', href: fax_logs_path)
			expect(page).to have_link("Phaxio Test Company", href: organization_path(org))
			expect(page).to have_link("Phaxio Test Company2", href: organization_path(org2))
			expect(page).to have_button("Delete Organization")
			expect(page).not_to have_button("Invite Manager") # Both orgs have a manager
		end

		it "allows the admin to create a new organization with no linked fax numbers. Manager invitation should not be an option until a fax number has been added" do
			login_as(admin)
			visit(organizations_path)
			click_on("Add New Organization")

			expect(page).to have_current_path("http://www.example.com/organizations/new")
			expect(page).to have_field("organization[label]")

			fill_in('organization[label]', with: "Brand New Organization")
			click_button("Submit")

			expect(page).to have_current_path('http://www.example.com/organizations')
			expect(page).to have_link("Brand New Organization")
			expect(page).not_to have_button("Invite Manager")
			expect(page).to have_text("You must link a fax number before you can invite a manager")
			expect(page).to have_text("Managed by: manager@phaxio.com")
			expect(page).to have_text("Managed by: manager2@phaxio.com")
		end

		it "redirects admin to the new_org_form if it cannot persist the new organization object" do
			login_as(admin)
			visit(organizations_path)
			click_on("Add New Organization")
			fill_in('organization[label]', with: "*" * (Organization::ORGANIZATION_CHARACTER_LIMIT + 1))
			click_button("Submit")

			expect(page).to have_current_path(new_organization_path)
			expect(page).to have_text("Label is too long (maximum is #{Organization::ORGANIZATION_CHARACTER_LIMIT} characters)")
		end

		it "redirects admin to the new_org_form if it cannot persist changes to an existing organization object" do
			login_as(admin)
			visit(organizations_path)
			click_on("Phaxio Test Company")
			click_on("Manage Phaxio Test Company Fax Numbers / Details")
			fill_in('organization[label]', with: "*" * (Organization::ORGANIZATION_CHARACTER_LIMIT + 1))
			click_button("Submit")

			expect(page).to have_current_path(edit_organization_path(org.id))
			expect(page).to have_text("Label is too long (maximum is #{Organization::ORGANIZATION_CHARACTER_LIMIT} characters)")
		end

		it "allows the admin to create a new organization with no linked fax numbers. Manager invitation should not be an option until a fax number has been added" do
			login_as(admin)
			visit(organizations_path)
			click_on("Add New Organization")
			expect(page).to have_current_path("http://www.example.com/organizations/new")
			expect(page).to have_field("organization[label]")
			fill_in('organization[label]', with: "Brand New Organization")
			click_button("Submit")
			expect(page).to have_current_path('http://www.example.com/organizations')
			expect(page).to have_link("Brand New Organization")
			expect(page).not_to have_button("Invite Manager")
		end

		it "allows the admin to create a new organization with a linked fax number. Manager invitation should not be an option until a fax number has been added." do
			login_as(admin)
			visit(organizations_path)
			click_on("Add New Organization")

			expect(page).to have_current_path("http://www.example.com/organizations/new")
			expect(page).to have_field("organization[label]")
			expect(page).to have_field("fax_numbers[to_add][#{fax_number3.id}]")

			check("fax_numbers[to_add][#{fax_number3.id}]")
			fill_in('organization[label]', with: "Organization With Fax Number")
			click_button("Submit")

			expect(page).to have_current_path('http://www.example.com/organizations')
			expect(page).to have_link("Organization With Fax Number")
			expect(page).to have_field("user[email]")
			expect(page).to have_select(
				"user[caller_id_number]",
				options: [ # will only have #3 b/c it's linked to that org
					"#{FaxNumber.format_pretty_fax_number(fax_number3.fax_number)}"
				]
			)
			expect(page).to have_button("Invite Manager")
		end

		it "the admin can delete an organization" do
			login_as(admin)
			visit(organizations_path)
			expect(page).to have_button('Delete Organization', count: 2)
			click_on("Delete Organization", match: :first)
			expect(page).to have_button('Delete Organization', count: 1)
			expect(page).not_to have_link("Phaxio Test Company", href: organization_path(org)) # <-- deleted Organization
			expect(page).to have_link("Phaxio Test Company2", href: organization_path(org2))
		end
	end

	describe "organization index when not logged in as an admin" do
		it "redirects to root if a non-admin user tries to access the organizations_path (index)" do
			login_as(user1)
			visit(organizations_path)
			expect(page).to have_current_path("http://www.example.com/")
			expect(page).to have_text(ApplicationController::DENIED)
		end

		it "redirects to root if a non-admin and non-manager user tries to access the organizations_path (index)" do
			login_as(manager)
			visit(organizations_path)
			expect(page).to have_current_path("http://www.example.com/")
			expect(page).to have_text(ApplicationController::DENIED)
		end

		it "redirects to sign_in if nobody is logged in" do
			visit(organizations_path)
			expect(page).to have_current_path("http://www.example.com/users/sign_in")
			expect(page).to have_text(ApplicationController::DENIED)
		end

		it "redirects a generic user to root if they try to access the edit page" do
			login_as(user1)
			visit(organization_path(org))
			expect(page).to have_current_path("http://www.example.com/")
			expect(page).to have_text(ApplicationController::DENIED)
		end

		it "redirects a manager assigned to a different organization to root if they try to access the edit page" do
			login_as(manager)
			visit(organization_path(org2))
			expect(page).to have_current_path("http://www.example.com/")
			expect(page).to have_text(ApplicationController::DENIED)
		end

		it "redirects to login if no user is signed in" do
			visit(organization_path(org2))
			expect(page).to have_current_path("http://www.example.com/users/sign_in")
			expect(page).to have_text(ApplicationController::DENIED)
		end
	end

	describe "organization show page functions" do
		describe "admin-level" do
			it "has proper admin visuals" do
				login_as(admin)
				visit(organization_path(org))

				expect(page).to have_link("Manage #{org.label} Fax Numbers / Details")
				expect(page).to have_link("#{org.label} Users")
				expect(page).to have_button("Provision Fax Number")

				expect(page).to have_link("#{FaxNumber.format_pretty_fax_number(fax_number1.fax_number)}")
				expect(page).to have_link("#{FaxNumber.format_pretty_fax_number(fax_number2.fax_number)}")
				expect(page).to have_link("Link / Unlink Users")

				expect(page).to have_text("Admin Label: OG Label")
				expect(page).to have_text("Manager Label: Manager-Set Label")

				expect(page).to have_table("#{org.fax_numbers.first.id}-users")
				within_table("#{org.fax_numbers.first.id}-users") do
					expect(page).to have_text("Email")
					expect(page).to have_text("Caller ID")
					expect(page).to have_text("matt@phaxio.com")
					expect(page).to have_text("#{FaxNumber.format_pretty_fax_number('+17738675309')}")
					expect(page).to have_text("matt2@phaxio.com")
					expect(page).to have_text("#{FaxNumber.format_pretty_fax_number('+17738675308')}")
					expect(page).not_to have_text("matt3@phaxio.com") # this shouldn't be in the table
				end

				expect(page).to have_table("#{org.fax_numbers.second.id}-users")
				within_table("#{org.fax_numbers.second.id}-users") do
					expect(page).to have_text("Email")
					expect(page).to have_text("Caller ID")
					expect(page).to have_text("matt@phaxio.com")
					expect(page).to have_text("#{FaxNumber.format_pretty_fax_number('+17738675309')}")
					expect(page).not_to have_text("matt2@phaxio.com")
					expect(page).not_to have_text("#{FaxNumber.format_pretty_fax_number('+17738675308')}")
				end
			end
		end

		it "manager level organization show page functions" do
			login_as(manager)
			visit(organization_path(org))
			expect(page).to have_link("#{org.label} Users")
			expect(page).to have_button("Provision Fax Number")
			expect(page).not_to have_link("Manage #{org.label} Fax Numbers / Details")
		end

		it "manager following Provision Fax Numbers link" do
			login_as(manager)
			visit(organization_path(org))
			click_button("Provision Fax Number")
			expect(page.current_path).to include(new_fax_number_path)
			expect(page).to have_field("fax_number[state]")
			expect(page).to have_field("fax_number[area_code]")
			expect(page).to have_button("Purchase Number")
		end

			it "admin following Provision Fax Numbers link" do
			login_as(admin)
			visit(organization_path(org))
			click_button("Provision Fax Number")
			expect(page.current_path).to include(new_fax_number_path)
			expect(page).to have_field("fax_number[state]")
			expect(page).to have_field("fax_number[area_code]")
			expect(page).to have_button("Purchase Number")
		end

		it "user level organization show page should deny and redirect to root" do
			login_as(user1)
			visit(organization_path(org))
			expect(page).to have_current_path("http://www.example.com/")
			expect(page).to have_text(ApplicationController::DENIED)
		end 
	end

	describe "creating a new organization" do
		it "redirects to root if a user attempts to access the new organization form" do
			login_as(user1)
			visit(new_organization_path)
			expect(page).to have_current_path("http://www.example.com/")
			expect(page).to have_text(ApplicationController::DENIED)
		end

		it "redirects to root if a user attempts to access the new organization form" do
			login_as(manager)
			visit(new_organization_path)
			expect(page).to have_current_path("http://www.example.com/")
			expect(page).to have_text(ApplicationController::DENIED)
		end
	end
end