require "rails_helper"

RSpec.feature "Fax Number Pages", :type => :feature do
	let! (:admin) do User.create!(
		email: 'fake@phaxio.com',
		user_permission_attributes: { permission: UserPermission::ADMIN }
	)
	end
	let!(:org) { Organization.create(label: "Phaxio Test Company", admin_id: admin.id) }
	let!(:user) do 
		User.create(
			email: 'matt@phaxio.com',
			user_permission_attributes: { permission: UserPermission::USER },
			caller_id_number: '17738675309',
			organization_id: org.id
		)
	end
	describe "the fax number index page" do
		it "redirects to the user_sign_in page if an admin is not logged in" do
			visit(fax_numbers_path)
			expect(page).to have_button("Log In")
			expect(page).to have_field("user[email]")
			expect(page).to have_field("user[password]")
			expect(page.current_url).to eq("http://www.example.com/users/sign_in")
			expect(page).to have_link('Log In', href: new_user_session_path)
			expect(page).to have_link(href: root_path)
		end

		it "displays the page when an admin is logged in" do
			login_as(admin)
			visit(fax_numbers_path)
			expect(page).to have_button('Log Out')
			expect(page).to have_link('Manage Clients', href: clients_path)
			expect(page).to have_link('Manage Numbers', href: fax_numbers_path)
			expect(page).to have_link('Edit')
			expect(page).to have_table('fax-number-table')
		end

		it "allows the admin to click the edit button in the table of fax numbers to edit it" do
			login_as(admin)
			visit(fax_numbers_path)
			click_on('Edit', match: :first)
			expect(page.current_url).to include('/edit')
			expect(page).to have_button("Save Changes")
			expect(page).to have_field("fax_number[label]")
			expect(page).to have_field("fax_number[organization_id]")
		end
	end
end