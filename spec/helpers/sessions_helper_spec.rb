RSpec.describe SessionsHelper, type: :helper do
  describe "SessionsHelper methods:" do
		let!(:admin) { User.create!(email: "admin@gmail.com", password: "admin!", type: "Admin") }
		let!(:manager) { User.create!(email: "manager@gmail.com", password: "admin!", type: "ClientManager") }
  	let!(:user) { User.create!(email: 'tom@tom.com', password: 'tomtom', client_id: 1, type: :User) }

		it "#login(user) adds the user_id to the session object" do
			login(user)
			expect(session[:user_id]).to eq(user.id)
		end

		it "#current_user returns nil if no one is logged in" do
			expect(current_user).to be_nil
		end

		it "#current_user returns the logged_in user when a user is logged in" do
			login(user)
			expect(current_user).to eq(user)
		end

		it "#authorized? returns false if the current_user does not match the id in params" do
			login(user)
			session_params = {id: user.id + 1}
			expect(authorized?(session_params)).to be(false)
		end

		it "#authorized? returns true if the current_user matches the id in params" do
			login(user)
			session_params = {id: user.id}
			expect(authorized?(session_params)).to be(true)
		end

		it "#logged_in? returns false if a user is not logged in" do
			expect(logged_in?).to be(false)
		end

		it "#logged_in? returns true if a user is logged in" do
			login(user)
			expect(logged_in?).to be(true)
		end

		it "#is_admin? returns true if the user 'type' attribute is 'Admin' " do
			login(user)
			expect(is_admin?).to be(false)
		end

		it "#is_admin? returns false is a user is not an admin" do
			login(admin)
			expect(is_admin?).to be(true)
			expect(is_client_manager?).to be(false)
		end

		it "#is_client_manager? returns true if a user 'type' attribute is 'ClientManager'" do
			login(manager)
			expect(is_admin?).to be(false)
			expect(is_client_manager?).to be(true)
		end
  end
end