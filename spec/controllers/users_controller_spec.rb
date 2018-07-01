require 'rails_helper'

RSpec.describe UsersController do
	it "gets the index page" do
		get :index
		expect(response.status).to eq(200)
		expect(response).to render_template(:index)
	end
end