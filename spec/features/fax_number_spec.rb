require "rails_helper"

#TODO: SWITCH A FAX NUMBER TO A DIFFERENT ORGANIZATION

RSpec.feature "Fax Number Pages", :type => :feature do
	let! (:admin) { User.create!( email: 'fake@phaxio.com', user_permission_attributes: { permission: UserPermission::ADMIN }) }
	let!(:org) { Organization.create(label: "Phaxio Test Company", admin_id: admin.id, fax_numbers_purchasable: true) }
	let!(:org2) { Organization.create(label: "Phaxio Test Company2", admin_id: admin.id) }
	let! (:manager) do 
		User.create!(email: 'manager@phaxio.com', user_permission_attributes: { permission: UserPermission::MANAGER },organization_id: org.id)
	end
	let! (:manager2) do
		User.create!(email: 'manager2@phaxio.com', user_permission_attributes: { permission: UserPermission::MANAGER }, organization_id: org2.id, caller_id_number: '17738675309')
	end
	let!(:user) do 
		User.create(email: 'matt@phaxio.com', user_permission_attributes: { permission: UserPermission::USER }, caller_id_number: '17738675309', organization_id: org.id)
	end
	let!(:user2) do 
		User.create!(email: 'not_fully_registered@phaxio.com', caller_id_number: '+17738675366', organization_id: org.id)
	end
	let!(:fax_number) { FaxNumber.create!(fax_number: '17738675309', organization_id: org.id) }

	before(:each) do 
		org.update_attributes(manager_id: manager.id)
		org2.update_attributes(manager_id: manager2.id)
		org.fax_numbers << fax_number
	end

	describe "the fax number index and edit page when logged in as an admin" do
		it "redirects to the user_sign_in page if no user is logged in" do
			visit(fax_numbers_path)
			expect(page).to have_button("Log In")
			expect(page).to have_field("user[email]")
			expect(page).to have_field("user[password]")
			expect(page).to have_current_path("http://www.example.com/users/sign_in")
			expect(page).to have_link('Log In', href: new_user_session_path)
			expect(page).to have_text(ApplicationController::DENIED)
		end

		it "displays the page when an admin is logged in" do
			login_as(admin)
			visit(fax_numbers_path)

			# Buy fax number form
			expect(page).to have_field("fax_number[state]")
			expect(page).to have_field("fax_number[area_code]")
			expect(page).to have_button("Purchase Number")
			
			# The following are the navbar links
			expect(page).to have_link('Organizations', href: organizations_path)
			expect(page).to have_link('Fax Numbers', href: fax_numbers_path)
			expect(page).to have_link('Edit Profile')
			expect(page).to have_link('Fax Logs', href: fax_logs_path)
			expect(page).to have_link('Users', href: '/org-users')

			expect(page).to have_button('Log Out')
			expect(page).to have_link('Edit')
			expect(page).to have_table('fax-number-table')
		end

		it "allows the admin to click the edit button in the table of fax numbers to edit it" do
			login_as(admin)
			visit(fax_numbers_path)

			within('#fax-number-table') { click_on('Edit', match: :first) }
			expect(page.current_url).to include('/edit')
			expect(page).not_to have_field("fax_number[manager_label]")
			expect(page).to have_field("fax_number[label]")
			expect(page).to have_select(
				"fax_number[organization_id]",
				options: [
					"#{org.label}",
					"#{org2.label}",
					"N/A (Removes this number from the organization)"
				]
			)
			expect(page).to have_button('Save Changes')

			fill_in('fax_number[label]', with: "New Label!")
			click_on('Save Changes')
			within('#fax-number-table') { click_on('Edit', match: :first) }
			expect(find_field('fax_number[label]').value).to eq('New Label!')
		end
	end

	describe "the fax_number index and edit page when not logged in as an admin" do
		it "redirects to root if a non-admin user tries to access the fax_numbers_path (index)" do
			login_as(user)
			visit(fax_numbers_path)
			expect(page).to have_current_path("http://www.example.com/")
			expect(page).to have_text(ApplicationController::DENIED)
		end

		it "redirects to root if a non-admin and non-manager user tries to access the fax_numbers_path (index)" do
			login_as(manager)
			visit(fax_numbers_path)
			expect(page).to have_current_path("http://www.example.com/")
			expect(page).to have_text(ApplicationController::DENIED)
		end

		it "redirects to root if a manager tries to access a fax_number that is not part of their organization" do
			login_as(manager2)
			visit(edit_fax_number_path(fax_number))
			expect(page).to have_current_path("http://www.example.com/")
			expect(page).to have_text(ApplicationController::DENIED)
		end

		it "redirects to sign_in if nobody is logged in" do
			visit(edit_fax_number_path(fax_number))
			expect(page).to have_current_path("http://www.example.com/users/sign_in")
			expect(page).to have_text(ApplicationController::DENIED)
		end

		it "allows a manager of a fax number to access its edit page but does not include the organization select tag" do
			login_as(manager)
			visit(edit_fax_number_path(fax_number))

			expect(page.current_url).to include('/edit')
			expect(page).to have_field("fax_number[manager_label]")
			expect(page).not_to have_field("fax_number[organization_id]")
			expect(page).to have_button('Save Changes')
			
			fill_in('fax_number[manager_label]', with: "New Manager Label!")
			click_on('Save Changes')
			expect(fax_number.reload.manager_label).to eq("New Manager Label!")
		end
	end

	describe "Provisioning fax numbers" do
		it "allows the manager to access the new_fax_number page if their account allows purchasing fax_numbers" do
			login_as(manager)
			visit(new_fax_number_path(params: {fax_number: {organization_id: org.id}}))
			expect(page.current_path).to include(new_fax_number_path)
			expect(page).to have_field("fax_number[state]")
			expect(page).to have_field("fax_number[area_code]")
			expect(page).to have_button("Purchase Number")
		end

		it "redirects if the manager tries to access the new_fax_number page if their account does not allow purchasing fax_numbers" do
			login_as(manager2)
			visit(new_fax_number_path(params: {fax_number: {organization_id: org2.id}}))
			expect(page).to have_current_path("http://www.example.com/")
			expect(page).to have_text(ApplicationController::DENIED)
		end

		it "redirects if the manager tries to access the new_fax_number page for an organization they are not the manager of. The organization they're attempting to access does allow fax number provisioning." do
			login_as(manager2)
			visit(new_fax_number_path(params: {fax_number: {organization_id: org.id}}))
			expect(page).to have_current_path("http://www.example.com/")
			expect(page).to have_text(ApplicationController::DENIED)
		end

		it "redirects if a generic user tries to access the new_fax_number page regardless of if the org fax_numbers_purchasable attribute is true or not" do
			login_as(user)
			visit(new_fax_number_path(params: {fax_number: {organization_id: org2.id}}))
			expect(page).to have_current_path("http://www.example.com/")
			expect(page).to have_text(ApplicationController::DENIED)

			visit(new_fax_number_path(params: {fax_number: {organization_id: org.id}}))
			expect(page).to have_current_path("http://www.example.com/")
			expect(page).to have_text(ApplicationController::DENIED)
		end
	end
end