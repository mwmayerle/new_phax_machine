require 'rails_helper'

RSpec.describe SessionsController, type: :controller do

	let!(:user) { User.create!(type: :User, username: "Fake User", password: 'tomtom', client_id: 1) }

	describe "logging in and logging out users" do
		it "does not log in the user when invalid credentials are provided" do
			post :create, params: {:session => {id: user.id, password: "nope", username: "Fake User"}}
			expect(response.status).to eq(200)
			expect(session[:user_id]).to eq(nil)
			expect(flash.now[:alert]).to eq("Invalid username or password. Please try again.")
			expect(response).to render_template(:new)
		end

		it "logs in the user when valid credentials are provided" do
			post :create, params: {:session => {id: user.id, password: "tomtom", username: "Fake User"} }
			expect(response.status).to eq(200)
			expect(session[:user_id]).to eq(user.id)
			expect(flash.now[:notice]).to eq("Welcome #{user.username}. You've been logged in.")
			expect(response).to render_template('users/show')
		end

		it "logs the user out when valid credentials are provided" do
			session[:user_id] = user.id
			delete :destroy, params: {:session => {id: user.id, username: user.username, password: user.password}}
			expect(response.status).to eq(302)
			expect(session[:user_id]).to be_nil
			expect(flash.now[:notice]).to eq("You've been logged out.")
			expect(response).to redirect_to root_path
		end

		it "does not log out the user when invalid/false credentials are provided" do
			session[:user_id] = user.id
			delete :destroy, params: {:session => {id: user.id + 1, username: user.username, password: user.password}}
			expect(response.status).to eq(302)
			expect(session[:user_id]).to eq(user.id)
			expect(flash.now[:alert]).to eq("Something went wrong.")
			expect(response).to redirect_to root_path
		end

		it "redirects the user to the homepage and tells them to log out before trying to log in" do
			session[:user_id] = user.id
			get :new
			expect(response.status).to eq(302)
			expect(session[:user_id]).to eq(user.id)
			expect(flash.now[:alert]).to eq("You must log out before you can log in.")
			expect(response).to redirect_to root_path
		end

		it "renders the login form is a user is not logged in" do
			get :new
			expect(response.status).to eq(200)
			expect(response).to render_template(:new)
		end
	end

end
