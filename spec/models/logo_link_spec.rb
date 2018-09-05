require 'rails_helper'

RSpec.describe LogoLink, type: :model do
	let!(:logo_link) { LogoLink.new(logo_url: "http://pigment.github.io/fake-logos/logos/large/color/space-cube.png")}

  it "is invalid if the link is over #{LogoLink::LOGO_LINK_LIMIT} characters" do
  	logo_link.logo_url = "*" * (LogoLink::LOGO_LINK_LIMIT + 1)
  	expect(logo_link).to be_invalid
	end

	it "is invalid if the link does not begin with http or https" do
		logo_link.logo_url = 'google.com'
  	expect(logo_link).to be_invalid
  	logo_link.logo_url = 'htp://www.google.com'
  	expect(logo_link).to be_invalid
  	logo_link.logo_url = 'google.com?=https://www.malicioussite.com'
  	expect(logo_link).to be_invalid
  	logo_link.logo_url = 'matt@phaxio.com'
  	expect(logo_link).to be_invalid
	end

	it "is invalid if the link is not an image" do
		logo_link.logo_url = 'h/sunny.freeservers.com/fun/flowers.txt'
  	expect(logo_link).to be_invalid
	end
end
