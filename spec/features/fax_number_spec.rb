require "rails_helper"

RSpec.feature "Fax Number Pages", :type => :feature do
	it "redirects to the user_sign_in page if an admin is not logged in" do
		visit fax_numbers_path
		expect(page).to have_button("Log In")
		expect(page).to have_field("user[email]")
		expect(page).to have_field("user[password]")
		expect(page.current_url).to eq("http://www.example.com/users/sign_in")
		expect(page).to have_link('Log In', href: new_user_session_path)
		expect(page).to have_link(href: root_path)
	end
end