require 'rails_helper'

RSpec.describe LogoLink, type: :model do
	let!(:logo_link) { LogoLink.new(logo_url: "http://pigment.github.io/fake-logos/logos/large/color/space-cube.png")}

  it "is invalid if the link is over #{LogoLink::LOGO_LINK_LIMIT} characters" do
  	logo_link.logo_url = "*" * (LogoLink::LOGO_LINK_LIMIT + 1)
  	expect(logo_link).to be_invalid
	end
end
