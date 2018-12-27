require "rails_helper"

RSpec.feature "User Profile", :type => :feature do
	let! (:admin) do
		User.create!(
			email: 'fake@phaxio.com',
			user_permission_attributes: { permission: UserPermission::ADMIN },
			password: "faxisawesome"
		)
	end
	let!(:org) { Organization.create!(label: "Phaxio Test Company", admin_id: admin.id) }
	let!(:org2) { Organization.create!(label: "Phaxio Test Company2", admin_id: admin.id) }
	let! (:manager) do 
		User.create!(email: 'manager@phaxio.com', user_permission_attributes: { permission: UserPermission::MANAGER }, organization_id: org.id, caller_id_number: '+17738675307', password: "fax-is-awesome-manager")
	end
	let! (:manager2) do
		User.create!(email: 'manager2@phaxio.com', user_permission_attributes: { permission: UserPermission::MANAGER }, organization_id: org2.id, caller_id_number: '+17738675309')
	end
	let!(:user1) do 
		User.create!(email: 'matt@phaxio.com', user_permission_attributes: { permission: UserPermission::USER }, caller_id_number: '+17738675309', organization_id: org.id, password: "tomtomtom")
	end
	let!(:user2) do 
		User.create!(email: 'matt2@phaxio.com', user_permission_attributes: { permission: UserPermission::USER }, caller_id_number: '+17738675308', organization_id: org.id)
	end
	let!(:user3) do 
		User.create!(email: 'matt3@phaxio.com', user_permission_attributes: { permission: UserPermission::USER }, caller_id_number: '+17738675309', organization_id: org.id)
	end
	let!(:fax_number1) { FaxNumber.create!(fax_number: "+17738675307", organization_id: org.id, org_switched_at: Time.now) }
	let!(:fax_number2) { FaxNumber.create!(fax_number: "+17738675308", organization_id: org.id, label: "OG Label", manager_label: "Manager-Set Label", org_switched_at: Time.now) }
	let!(:fax_number3) { FaxNumber.create!(fax_number: "+17738675309", org_switched_at: Time.now) }
	let!(:logo) { LogoLink.create!(logo_url: "https://usatftw.files.wordpress.com/2017/01/yourface.png?w=1000") }

	before(:each) do 
		org.update_attributes(manager_id: manager.id)
		org2.update_attributes(manager_id: manager2.id)
		org.reload.fax_numbers << fax_number1
		org.reload.fax_numbers << fax_number2
		org.reload.users << user1
		org.reload.users << user2
		user1.reload.fax_numbers << fax_number1
		user1.reload.fax_numbers << fax_number2
		user2.reload.fax_numbers << fax_number1
	end

	describe "user profile permissions" do
		it "a generic user and manager do not have a field to edit the logo" do
			login_as(user1)
			visit(root_path)
			click_link('Edit Profile')
			expect(page).to have_current_path(edit_user_registration_path)
			expect(page).to have_field("user[password]")
			expect(page).to have_field("user[password_confirmation]")
			expect(page).not_to have_field("user[logo_url]") # only admin gets this
			expect(page).to have_field("user[current_password]")
			expect(page).to have_button("Update")
			click_on("Log Out")

			login_as(manager)
			visit(root_path)
			click_link('Edit Profile')
			expect(page).to have_current_path(edit_user_registration_path)
			expect(page).to have_field("user[password]")
			expect(page).to have_field("user[password_confirmation]")
			expect(page).not_to have_field("user[logo_url]") # only admin gets this
			expect(page).to have_field("user[current_password]")
			expect(page).to have_button("Update")
			click_on("Log Out")

			login_as(admin)
			visit(root_path)
			click_link('Edit Profile')
			expect(page).to have_current_path(edit_user_registration_path)
			expect(page).to have_field("user[password]")
			expect(page).to have_field("user[password_confirmation]")
			expect(page).to have_field("user[logo_url]") # only admin gets this
			expect(page).to have_field("user[current_password]")
			expect(page).to have_button("Update")
		end
		it "Admin can successfully edit their profile and the logo link with proper credentials" do
			login_as(admin)
			visit(edit_user_registration_path(admin))
			fill_in("user[password]", with: user1.password)# tomtomtom
			fill_in("user[password_confirmation]", with: user1.password)
			fill_in("user[current_password]", with: admin.password) # faxisawesome
			fill_in("user[logo_url]", with: "https://usatftw.files.wordpress.com/2017/01/yourface.png?w=1000")
			click_button("Update")
			expect(LogoLink.first.logo_url).to eq("https://usatftw.files.wordpress.com/2017/01/yourface.png?w=1000")
			expect(page).to have_current_path(fax_numbers_path)
			expect(page).to have_text("Your account has been updated successfully. Logo successfully updated")
		end

		it "Admin can change their password without affecting the logo link" do
			login_as(admin)
			visit(edit_user_registration_path(admin))
			fill_in("user[password]", with: user1.password)# tomtomtom
			fill_in("user[password_confirmation]", with: user1.password)
			fill_in("user[current_password]", with: admin.password) # faxisawesome
			click_button("Update")
			expect(LogoLink.first.logo_url).to eq("https://usatftw.files.wordpress.com/2017/01/yourface.png?w=1000")
			expect(page).to have_current_path(fax_numbers_path)
			expect(page).to have_text("Your account has been updated successfully.")
		end

		it "Admin can change their password despite having an invalid logo link" do
			login_as(admin)
			visit(edit_user_registration_path)
			fill_in("user[password]", with: user1.password)# tomtomtom
			fill_in("user[password_confirmation]", with: user1.password)
			fill_in("user[current_password]", with: admin.password) # faxisawesome
			fill_in("user[logo_url]", with: ("*" * 1001))
			click_button("Update")
			expect(LogoLink.first.logo_url).to eq("https://usatftw.files.wordpress.com/2017/01/yourface.png?w=1000")
			expect(page).to have_current_path(user_registration_path)
			expect(page).to have_text("Your account has been updated successfully. However, the logo URL must link to an image. Please try again.")
		end

		it "Manager can successfully edit their profile with proper credentials" do
			login_as(manager)
			visit(edit_user_registration_path)
			fill_in("user[password]", with: user1.password)# tomtomtom
			fill_in("user[password_confirmation]", with: user1.password)
			fill_in("user[current_password]", with: manager.password) # fax-is-awesome-manager
			click_button("Update")
			expect(page).to have_text("Your account has been updated successfully.")
		end

		it "a generic user can successfully edit their profile with proper credentials" do
			login_as(user1)
			visit(edit_user_registration_path)
			fill_in("user[password]", with: manager.password)# fax-is-awesome-manager
			fill_in("user[password_confirmation]", with: manager.password)
			fill_in("user[current_password]", with: user1.password) # tomtomtom
			click_button("Update")
			expect(page).to have_text("Your account has been updated successfully.")
		end
	end

	describe "editing your profile when no LogoLink object exists" do
		it "should create a new LogoLink object" do
			logo = nil
			LogoLink.destroy_all
			login_as(admin)
			visit(edit_user_registration_path)
			fill_in("user[password]", with: manager.password)
			fill_in("user[password_confirmation]", with: manager.password)
			fill_in("user[current_password]", with: admin.password)
			fill_in("user[logo_url]", with: "http://pigment.github.io/fake-logos/logos/large/color/fast-banana.png")
			click_button("Update")
			expect(page).to have_text("Your account has been updated successfully. Logo successfully created.")
		end
	end
end