require 'rails_helper'

RSpec.describe Admin, type: :model do
  describe "creating an admin with valid input" do

  	before(:each) do
    	@admin = Admin.new(admin_email: 'tom@tom.com', password: 'tomtom')
  	end

  	it "has an admin email" do
  		expect(@admin.valid?).to be true
  		expect(@admin.save).to be true
  	end

  	it "has a password" do
  		expect(@admin.valid?).to be true
  		expect(@admin.save).to be true
  	end
  end

  describe "creating an admin with invalid input" do
  	before(:each) do
    	@admin = Admin.new(admin_email: 'tom@tom.com', password: 'tomtom')
  	end
  	it "requires the email to be unique" do
  		@admin.save
  		@admin2 = Admin.new(admin_email: 'tom@tom.com', password: 'tomtom')
  		expect(@admin2.valid?).to be false
  		expect(@admin2.save).to be false
  	end

  	it "has a maximum length of 60" do
  		@admin.admin_email = ("a" * 60).concat('@aol.com')
  		expect(@admin.valid?).to be false
  		expect(@admin.save).to be false
  	end

  	#NEEDS EMAIL VALIDATION
  end
end
