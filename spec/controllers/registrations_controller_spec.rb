require 'rails_helper'

RSpec.describe Users::RegistrationsController do

	before :each do
  	request.env['devise.mapping'] = Devise.mappings[:registrations]
	end

	it "fails hard" do
		get :new
		expect(response.status).to eq(200)
	end
end