require 'rails_helper'

RSpec.describe FaxNumbersController, type: :controller do
	let!(:admin) {User.create!(type: :Admin, username: "Admin", password: 'testadmin')}
	let!(:client_manager) { User.create!(type: :ClientManager, username: "Client", password: "testmanager") }
	let!(:client) {Client.create!(admin_id: admin.id, client_manager_id: client_manager.id, client_label: "Fax Number Test Client")}
	let!(:fax_number) { FaxNumber.create!(fax_number: '12248675309', fax_number_label: "Fake Testing Number1", client_id: client.id) }
	let!(:fax_number2) { FaxNumber.create!(fax_number: '12248675310', fax_number_label: "Fake Testing Number2", client_id: client.id) }
	let!(:user) { User.create!(type: :User, username: "User1", password: 'tomtom', client_id: client.id) }

	describe "if the user is an admin" do
		it "#index only accessible if the User is an admin" do
			session[:user_id] = admin.id
			get :index
			expect(response.status).to eq(200)
			expect(response).to render_template(:index)
		end

		it "#new only accessible if the User is an admin" do
			session[:user_id] = admin.id
			get :new
			expect(response.status).to eq(200)
			expect(response).to render_template(:new)
		end

		it "#create only accessible if the User is an admin, and it creates a new fax number with valid input, redirecting to the index" do
			fax_number_amount = FaxNumber.all.count
			session[:user_id] = admin.id
			post :create, params: { fax_number: { fax_number: '12248675311', fax_number_label: "Test Fax Number" } }
			expect(response.status).to eq(302)
			expect(flash[:notice]).to eq("Fax number successfully saved.")
			expect(response).to redirect_to fax_numbers_path
			expect(FaxNumber.all.count).to eq(fax_number_amount + 1)
		end

		it "#create only accessible if the User is an admin, renders 'new' if invalid inputs are provided" do
			fax_number_amount = FaxNumber.all.count
			session[:user_id] = admin.id
			post :create, params: { fax_number: { fax_number: 'eeeeeeee', fax_number_label: "Test Fax Number" } }
			expect(response.status).to eq(200)
			expect(flash[:alert]).to eq("Fax number is invalid")
			expect(response).to render_template(:new)
			expect(FaxNumber.all.count).to eq(fax_number_amount)
		end

		# it "#edit only accessible if the User is an admin, renders 'new' if invalid inputs are provided" do
		# 	@fax_number = FaxNumber.find(fax_number.id)
		# 	session[:user_id] = admin.id
		# 	@fax_number = FaxNumber.find(fax_number.id)
		# 	get :edit
		# 	expect(response.status).to eq(200)
		# 	expect(response).to render_template(:edit)
		# end

		# it "#update only accessible if the User is an admin, renders 'new' if invalid inputs are provided" do
		# 	session[:user_id] = admin.id
		# 	put :update, params: { fax_number: { fax_number: '12248675311', fax_number_label: "Edited Label" } }
		# 	expect(response.status).to eq(302)
		# 	expect(response).to redirect_to(:index)
		# end

		#TODO DELETE ROUTE TESTS
	end

	describe "if the user is not an admin or not logged in" do
		it "#create redirects to home if user is not an Admin" do
			session[:user_id] = client_manager.id
			post :create, params: { fax_number: { fax_number: '12248675311', fax_number_label: "Test Fax Number" } }
			expect(response.status).to eq(302)
			expect(flash[:alert]).to eq("Permission denied.")
			expect(response).to redirect_to root_path

			session[:user_id] = user.id
			post :create, params: { fax_number: { fax_number: '12248675311', fax_number_label: "Test Fax Number" } }
			expect(response.status).to eq(302)
			expect(flash[:alert]).to eq("Permission denied.")
			expect(response).to redirect_to root_path

			session[:user_id] = nil
			post :create, params: { fax_number: { fax_number: '12248675311', fax_number_label: "Test Fax Number" } }
			expect(response.status).to eq(302)
			expect(flash[:alert]).to eq("Permission denied.")
			expect(response).to redirect_to root_path
		end

		it "#new redirects to home if user is not an Admin or not logged in" do
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

			session[:user_id] = nil
			get :new
			expect(response.status).to eq(302)
			expect(flash[:alert]).to eq("Permission denied.")
			expect(response).to redirect_to root_path
		end

		it "#index redirects to home if user is not an Admin or not logged in" do
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

			session[:user_id] = nil
			get :index
			expect(response.status).to eq(302)
			expect(flash[:alert]).to eq("Permission denied.")
			expect(response).to redirect_to root_path
		end

	end

end
