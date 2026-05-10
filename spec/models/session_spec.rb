RSpec.describe Session, type: :model do
  let(:user) { User.create!(email_address: "test@example.com", password: "password") }

  describe "アソシエーション" do
    it "ユーザーに属する" do
      session = Session.create!(user: user, user_agent: "test", ip_address: "127.0.0.1")
      expect(session.user).to eq(user)
    end

    it "ユーザーなしでは無効" do
      session = Session.new(user_agent: "test", ip_address: "127.0.0.1")
      expect(session).not_to be_valid
    end
  end
end
