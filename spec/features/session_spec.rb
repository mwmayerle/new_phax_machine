require "rails_helper"

# This page bleeds heavily into the Organization tests
RSpec.feature "Sessions (Login/Logout)", :type => :feature do
	let! (:admin) do 
		User.create!( email: 'fake@phaxio.com', user_permission_attributes: { permission: UserPermission::ADMIN }, password: "faxisawesome" )
	end
	let!(:org) { Organization.create(label: "Phaxio Test Company", admin_id: admin.id) }
	let! (:manager) do 
		User.create!(email: 'manager@phaxio.com', user_permission_attributes: { permission: UserPermission::MANAGER }, organization_id: org.id, caller_id_number: '+17738675307', password: "faxisawesome" )
	end
	let!(:user) do 
		User.create(email: 'matt@phaxio.com', user_permission_attributes: { permission: UserPermission::USER }, caller_id_number: '+17738675309', organization_id: org.id)
	end
	let!(:fax_number) do
		FaxNumber.create!(fax_number: '+17738675308', organization_id: org.id, label: "OG Label", manager_label: "Manager-Set Label", org_switched_at: Time.now)
	end

	describe "logging in" do
		it "a user who is not logged in will be redirected to the sign in page" do
			visit(fax_numbers_path)
			expect(page).to have_current_path("http://www.example.com/users/sign_in")
			expect(page).to have_text(ApplicationController::DENIED)

			visit(organizations_path)
			expect(page).to have_current_path("http://www.example.com/users/sign_in")
			expect(page).to have_text(ApplicationController::DENIED)

			visit(edit_fax_number_path(fax_number))
			expect(page).to have_current_path("http://www.example.com/users/sign_in")
			expect(page).to have_text(ApplicationController::DENIED)

			visit(organization_path(org))
			expect(page).to have_current_path("http://www.example.com/users/sign_in")
			expect(page).to have_text(ApplicationController::DENIED)

			expect(page).to have_link("Log In", href: "/users/sign_in")
			click_on("Log In")
			expect(page).to have_link("Log In", href: "/users/sign_in")
			expect(page).to have_button("Log In")
			expect(page).to have_field("user[email]")
			expect(page).to have_field("user[password]")
			expect(page).to have_field('user[rememberme]', checked: false)
			expect(page).to have_link("Forgot your password?", href: "/users/password/new")
		end
	end

	describe "logging out users" do
		it "logs out each type of user" do
			login_as(admin)
			visit(fax_numbers_path)
			expect(page).to have_button("Log Out")
			click_on("Log Out")
			expect(page).to have_current_path(new_user_session_path)

			login_as(manager)
			visit(organizations_path(org))
			expect(page).to have_button("Log Out")
			click_on("Log Out")
			expect(page).to have_current_path(new_user_session_path)

			login_as(user)
			visit(new_fax_path)
			expect(page).to have_button("Log Out")
			click_on("Log Out")
			expect(page).to have_current_path(new_user_session_path)
		end
	end

end