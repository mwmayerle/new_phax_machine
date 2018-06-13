require 'rails_helper'

RSpec.describe ClientsController, type: :controller do
	let!(:admin) {User.create!(type: :Admin, username: "Admin", password: 'testadmin')}
	let!(:client_manager) { User.create!(type: :ClientManager, username: "Client", password: "testmanager") }
	let!(:client) {Client.create!(admin_id: admin.id, client_manager_id: client_manager.id, client_label: "Client Controller Test Client")}
	let!(:fax_number) { FaxNumber.create!(fax_number: '12248675309', fax_number_label: "Fake Testing Number1") }
	let!(:fax_number2) { FaxNumber.create!(fax_number: '12248675310', fax_number_label: "Fake Testing Number2") }
	let!(:user) { User.create!(type: :User, username: "User1", password: 'tomtom', client_id: client.id) }

	it "#new is only accessible by an admin" do
		session[:user_id] = admin.id
		get :new
		expect(response.status).to eq(200)
		expect(response).to render_template(:new)
	end

	it "#new is not accessible by client managers or regular users" do
		session[:user_id] = client_manager.id
		get :new
		expect(response.status).to eq(302)
		expect(flash[:alert]).to eq("Permission denied.")
		expect(response).to redirect_to root_path

		session[:user_id] = user.id
		get :new
		expect(response.status).to eq(302)
		expect(flash[:alert]).to eq("Permission denied.")
		expect(response).to redirect_to root_path
	end

		it "#index is only accessible by an admin" do
		session[:user_id] = admin.id
		get :index
		expect(response.status).to eq(200)
		expect(response).to render_template(:index)
	end

	it "#index is not accessible by client managers or regular users" do
		session[:user_id] = client_manager.id
		get :index
		expect(response.status).to eq(302)
		expect(flash[:alert]).to eq("Permission denied.")
		expect(response).to redirect_to root_path

		session[:user_id] = user.id
		get :index
		expect(response.status).to eq(302)
		expect(flash[:alert]).to eq("Permission denied.")
		expect(response).to redirect_to root_path
	end

	it "#create is only accessible by admin and creates a new Client object" do
		client_count = Client.all.count
		session[:user_id] = admin.id
		post :create, params: { client: { admin_id: admin.id, client_manager_id: client_manager.id, client_label: "Client Controller Test Client2"} }
		expect(flash[:notice]).to eq("Client created successfully.")
		expect(response.status).to eq(302)
		expect(response).to redirect_to clients_path
		expect(client_count + 1).to eq(Client.all.count)
	end

	it "#create associates the desired fax_numbers" do
		client_count = Client.all.count
		session[:user_id] = admin.id
		post :create, params: {fax_numbers: { to_add: { fax_number.id => fax_number.fax_number , fax_number2.id => fax_number2.fax_number } }, client: { admin_id: admin.id, client_manager_id: client_manager.id, client_label: "Assoc Fax Number Test"} }
		expect(flash[:notice]).to eq("Client created successfully.")
		expect(response.status).to eq(302)
		expect(response).to redirect_to clients_path
		expect(client_count + 1).to eq(Client.all.count)
		associated_fax_numbers = FaxNumber.where(client_id: Client.last.id)
		expect(associated_fax_numbers).to include(fax_number)
		expect(associated_fax_numbers).to include(fax_number2)
	end

	it "#create redirects to :new if invalid params are provided" do
		session[:user_id] = admin.id
		post :create, params: { client: { admin_id: admin.id, client_manager_id: client_manager.id, client_label: "*" * 100} }
		expect(flash[:alert]).to eq("Client label is too long (maximum is 32 characters)")
		expect(response.status).to eq(200)
		expect(response).to render_template :new
	end

	it "#create redirects to root is the user is not an Admin" do
		client_count = Client.all.count
		session[:user_id] = client_manager.id
		post :create, params: { client: { admin_id: admin.id, client_manager_id: client_manager.id, client_label: "Client Controller Test Client3"} }
		expect(flash[:alert]).to eq("Permission denied.")
		expect(response.status).to eq(302)
		expect(response).to redirect_to root_path
		expect(client_count).to eq(Client.all.count)

		session[:user_id] = user.id
		post :create, params: { client: { admin_id: admin.id, client_manager_id: client_manager.id, client_label: "Client Controller Test Client3"} }
		expect(flash[:alert]).to eq("Permission denied.")
		expect(response.status).to eq(302)
		expect(response).to redirect_to root_path
		expect(client_count).to eq(Client.all.count)
	end

	# it "#show is only accessible by the client_manager or the admin" do
	# 	session[:user_id] = admin.id
	# 	get :show, params: {:client => {:id => client.id}}
	# 	expect(response.status).to eq(200)
	# 	expect(response).to render_template :show
	# end
end
