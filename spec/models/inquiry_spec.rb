RSpec.describe Inquiry, type: :model do
  describe "バリデーション" do
    it "name・email・body があれば有効" do
      inquiry = Inquiry.new(name: "山田太郎", email: "test@example.com", body: "お問い合わせ内容")
      expect(inquiry).to be_valid
    end

    it "name が空なら無効" do
      inquiry = Inquiry.new(name: "", email: "test@example.com", body: "お問い合わせ内容")
      expect(inquiry).not_to be_valid
    end

    it "email が空なら無効" do
      inquiry = Inquiry.new(name: "山田太郎", email: "", body: "お問い合わせ内容")
      expect(inquiry).not_to be_valid
    end

    it "email の形式が不正なら無効" do
      inquiry = Inquiry.new(name: "山田太郎", email: "invalid-email", body: "お問い合わせ内容")
      expect(inquiry).not_to be_valid
    end

    it "body が空なら無効" do
      inquiry = Inquiry.new(name: "山田太郎", email: "test@example.com", body: "")
      expect(inquiry).not_to be_valid
    end

    it "name が101文字以上なら無効" do
      inquiry = Inquiry.new(name: "あ" * 101, email: "test@example.com", body: "お問い合わせ内容")
      expect(inquiry).not_to be_valid
    end

    it "email が255文字以上なら無効" do
      inquiry = Inquiry.new(name: "山田太郎", email: "#{"a" * 243}@example.com", body: "お問い合わせ内容")
      expect(inquiry).not_to be_valid
    end

    it "body が2001文字以上なら無効" do
      inquiry = Inquiry.new(name: "山田太郎", email: "test@example.com", body: "あ" * 2001)
      expect(inquiry).not_to be_valid
    end

    it "read のデフォルトは false" do
      inquiry = Inquiry.create!(name: "山田太郎", email: "test@example.com", body: "お問い合わせ内容")
      expect(inquiry.read).to be false
    end
  end
end
