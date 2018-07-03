require "rails_helper"

RSpec.feature "Edit Fax Number", :type => :feature do

	let!(:admin) {User.create!(type: :Admin, email: "mwmayerle@gmail.com", password: 'tomtom')}
	let!(:client) {Client.create!(admin_id: admin.id, client_label: "Client Controller Test Client")}
	let!(:client_manager) {User.create!(type: :ClientManager, email: "matt@phaxio.com", client_id: client.id)}
	let!(:user1) {User.create!(email: "user1@gmail.com", client_id: client.id)}
	let!(:fax_number) {FaxNumber.create!(fax_number: '12025550134', fax_number_label: "Fake1", client_id: client.id)}
	let!(:user_email1) {UserEmail.create!(user_id: user1.id, email_address: 'user1@gmail.com', client_id: client.id, caller_id_number: fax_number.fax_number)}
	let!(:user_email2) {UserEmail.create!(user_id: client.id, email_address: 'matt@phaxio.com', client_id: client.id, caller_id_number: fax_number.fax_number)}

	before(:each) { client.update(client_manager_id: client_manager.id) }

  scenario "Admin visits the edit page" do
  	sign_in(admin)

    visit "/fax_numbers/#{fax_number.id}/edit"
    expect(page).to have_text("Edit Fax Number (+12025550134)")
    expect(page).to have_field("Fax Number Label:")
    expect(page).to have_field("Client-Set Fax Number Label:")
    expect(page).to have_content("Client:")
    expect(page).to have_text("Link These Emails to +12025550134")
  end

  scenario "Client Manager visits the edit page" do
  	sign_in(client_manager)

    visit "/fax_numbers/#{fax_number.id}/edit"
    expect(page).to have_text("Manage Linked Emails for +12025550134")
    expect(page).to have_field("Fax Number Label:")
    expect(page).to have_text("Link These Emails to +12025550134")

    expect(page).not_to have_field("Client-Set Fax Number Label:")
    expect(page).not_to have_content("Client:")
  end
end
    # within("#fax-number-labels") do
    #   fill_in 'fax_number[fax_number_label]', with: 'Admin-Only Test Label'
    #   fill_in 'fax_number[fax_number_display_label]', with: 'Client Label'
    # end