require "rails_helper"

RSpec.feature "Readme Pages", :type => :feature do

	let! (:admin) { User.create!( email: 'fake@phaxio.com', user_permission_attributes: { permission: UserPermission::ADMIN }) }
	let!(:org) { Organization.create!(label: "Phaxio Test Company", admin_id: admin.id, fax_numbers_purchasable: true) }
	let! (:manager) do 
		User.create!(email: 'manager@phaxio.com', user_permission_attributes: { permission: UserPermission::MANAGER }, organization_id: org.id, caller_id_number: '+17738675307')
	end
	let!(:user) do 
		User.create!(email: 'matt@phaxio.com', user_permission_attributes: { permission: UserPermission::USER }, caller_id_number: '+17738675309', organization_id: org.id)
	end

	before(:each) do 
		org.update_attributes(manager_id: manager.id)
		org.users << user
	end

	describe "readme page navigation based on permissions" do
		it "redirects to the user_sign_in page if no user is logged in" do
			visit('/readme')
			expect(page).to have_button("Log In")
			expect(page).to have_field("user[email]")
			expect(page).to have_field("user[password]")
			expect(page).to have_current_path("http://www.example.com/users/sign_in")
			expect(page).to have_link('Log In', href: new_user_session_path)
		end

		it "renders the admin-help page when logged in as an admin" do
			login_as(admin)
			visit('/readme')
			expect(page).to have_text("User Guide - Admin")
		end

		it "renders the manager-help page when logged in as an manager" do
			login_as(manager)
			visit('/readme')
			expect(page).to have_text("User Guide - Manager")
		end

		it "renders the user-help page when logged in as an user" do
			login_as(user)
			visit('/readme')
			expect(page).to have_text("User Guide")
		end

	end
end