require 'rails_helper'

RSpec.describe Admin, type: :model do
  describe "creating an admin with valid input" do

  	before(:each) do
    	@admin = Admin.new(admin_email: 'tom@tom.com', password: 'tomtom')
  	end

  	it "has valid attributes" do
  		expect(@admin).to be_valid
  	end
  end

  describe "creating an admin with invalid input" do
  	before(:each) do
    	@admin = Admin.new(admin_email: 'tom@tom.com', password: 'tomtom')
  	end

  	it "is not valid without an email" do
  		@admin.admin_email = nil
  		expect(@admin).to be_invalid
  	end

  	it "is not valid without password" do
  		@admin.password = nil
  		expect(@admin).to be_invalid
  	end

  	it "requires the email to be unique" do
  		@admin.save
  		@admin2 = Admin.new(admin_email: 'tom@tom.com', password: 'tomtom')
  		expect(@admin2).to be_invalid
  	end

  	it "has a maximum length of 60" do
  		@admin.admin_email = ("a" * 60).concat('@aol.com')
  		expect(@admin).to be_invalid
  	end

  	#NEEDS EMAIL VALIDATION
  end
end
