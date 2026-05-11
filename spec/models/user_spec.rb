RSpec.describe User, type: :model do
  describe "バリデーション" do
    it "メールアドレスとパスワードがあれば有効" do
      user = User.new(email_address: "test@example.com", password: "password")
      expect(user).to be_valid
    end

    it "メールアドレスがなければ無効" do
      user = User.new(password: "password")
      expect(user).not_to be_valid
    end

    it "パスワードがなければ無効" do
      user = User.new(email_address: "test@example.com")
      expect(user).not_to be_valid
    end

    it "メールアドレスが重複していれば無効" do
      User.create!(email_address: "test@example.com", password: "password")
      user = User.new(email_address: "test@example.com", password: "password")
      expect(user).not_to be_valid
    end
  end

  describe "normalizes" do
    it "メールアドレスを小文字に正規化する" do
      user = User.create!(email_address: "TEST@EXAMPLE.COM", password: "password")
      expect(user.email_address).to eq("test@example.com")
    end

    it "メールアドレスの前後の空白を除去する" do
      user = User.create!(email_address: "  test@example.com  ", password: "password")
      expect(user.email_address).to eq("test@example.com")
    end
  end

  describe "admin フラグ" do
    it "デフォルトで true になる" do
      user = User.create!(email_address: "test@example.com", password: "password")
      expect(user.admin?).to be true
    end
  end

  describe "アソシエーション" do
    it "ユーザー削除時にセッションも削除される" do
      user = User.create!(email_address: "test@example.com", password: "password")
      user.sessions.create!(user_agent: "test", ip_address: "127.0.0.1")
      expect { user.destroy }.to change(Session, :count).by(-1)
    end

    it "記事があるユーザーは削除できない" do
      user = User.create!(email_address: "test@example.com", password: "password")
      BlogPost.create!(title: "テスト記事", slug: "test", user: user)
      expect { user.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
    end

    it "記事がないユーザーは削除できる" do
      user = User.create!(email_address: "test@example.com", password: "password")
      expect { user.destroy }.to change(User, :count).by(-1)
    end
  end
end
