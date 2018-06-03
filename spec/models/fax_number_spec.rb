require 'rails_helper'

# not testing the validity of numbers due to Phonelib's inclusion

RSpec.describe FaxNumber, type: :model do

  describe "valid fax number formatting" do
  	before(:each) do
    	@fax_number = FaxNumber.new(fax_number: '12248675309', fax_number_label: "Fake Testing Number")
  	end

  	it "persists to the database only if fax number is present" do
  		expect(@fax_number.valid?).to be true
  		expect(@fax_number.save).to be true
  	end

  	it "does not require a fax_number label" do
  		@fax_number.fax_number_label = nil
  		expect(@fax_number.valid?).to be true
  		expect(@fax_number.save).to be true
  	end

  end

  describe "invalid fax number formatting" do
  	before(:each) do
    	@fax_number = FaxNumber.new
  	end

  	it "persists to the database only if fax number is present" do
  		expect(@fax_number.valid?).to be false
  		expect(@fax_number.save).to be false
  	end

  	it "fax label cannot be more than 48 characters long" do
  		@fax_number.fax_number = '12248675309'
  		@fax_number.fax_number_label = "A" * 49
  		expect(@fax_number.valid?).to be false
  		expect(@fax_number.save).to be false
  	end

  	it "fax_number must be unique" do
  		@fax_number = FaxNumber.create(fax_number: '12248675309', fax_number_label: "Fake Testing Number")
  		@fax_number2 = FaxNumber.new(fax_number: '12248675309', fax_number_label: "Different Fake Testing Number")
  		expect(@fax_number2.valid?).to be false
  		expect(@fax_number2.save).to be false
  	end
  end
end
