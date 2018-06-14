require 'rails_helper'

RSpec.describe EmailsController, type: :controller do
	let!(:admin) {User.create!(type: :Admin, username: "Admin", password: 'testadmin')}
	let!(:client_manager) { User.create!(type: :ClientManager, username: "Client", password: "testmanager") }
	let!(:wrong_client_manager) { User.create!(type: :ClientManager, username: "WrongClient", password: "testmanager") }
	let!(:client) {Client.create!(admin_id: admin.id, client_manager_id: client_manager.id, client_label: "Fax Number Test Client")}
	let!(:fax_number) { FaxNumber.create!(fax_number: '12248675309', fax_number_label: "Fake Testing Number1", client_id: client.id) }
	let!(:fax_number2) { FaxNumber.create!(fax_number: '12248675310', fax_number_label: "Fake Testing Number2", client_id: client.id) }
	let!(:email) { Email.new(caller_id_number: fax_number.fax_number, client_id: client.id, email: "test@aol.com") }

	describe "when logged in as the Client object's client_manager or an Admin" do
		it "#new, only the client_manager or admin can reach the new email form" do
			session[:user_id] = client_manager.id
			get :new, params: { id: fax_number.id }
			expect(response.status).to eq(200)
			expect(response).to render_template(:new)

			session[:user_id] = admin.id
			get :new, params: { id: fax_number.id }
			expect(response.status).to eq(200)
			expect(response).to render_template(:new)
		end

		it "#create, a new email may only be created by an Admin or the client_manager" do
			session[:user_id] = admin.id
			post :create, params: { email: { caller_id_number: fax_number.fax_number, client_id: client.id, email: "test@aol.com", fax_number_id: fax_number.id } }
			expect(flash[:notice]).to eq("Email successfully created.")
			expect(response.status).to eq(302)
			expect(response).to redirect_to client_path(id: client.id)

			session[:user_id] = client_manager.id
			post :create, params: { email: { caller_id_number: fax_number.fax_number, client_id: client.id, email: "test2@aol.com", fax_number_id: fax_number.id } }
			expect(flash[:notice]).to eq("Email successfully created.")
			expect(response.status).to eq(302)
			expect(response).to redirect_to client_path(id: client.id)
		end
	end

end
