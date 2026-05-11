RSpec.describe Category, type: :model do
  describe "バリデーション" do
    it "name があれば有効" do
      category = Category.new(name: "Ruby")
      expect(category).to be_valid
    end

    it "name が空なら無効" do
      category = Category.new(name: "")
      expect(category).not_to be_valid
    end

    it "name が 51 文字以上なら無効" do
      category = Category.new(name: "a" * 51)
      expect(category).not_to be_valid
    end

    it "name が 50 文字なら有効" do
      category = Category.new(name: "a" * 50)
      expect(category).to be_valid
    end

    it "name が重複なら無効" do
      Category.create!(name: "Ruby")
      category = Category.new(name: "Ruby")
      expect(category).not_to be_valid
    end
  end

  describe "スコープ" do
    it "ordered は name 昇順で返す" do
      Category.create!(name: "Rails")
      Category.create!(name: "AWS")
      Category.create!(name: "Docker")
      names = Category.ordered.map(&:name)
      expect(names).to eq(%w[AWS Docker Rails])
    end
  end

  describe "アソシエーション" do
    it "削除時に関連する blog_post の category_id が nil になる" do
      category = Category.create!(name: "Ruby")
      user = User.create!(email_address: "test@example.com", password: "password")
      post = BlogPost.create!(title: "Test", slug: "test", user: user, category: category)

      category.destroy
      expect(post.reload.category_id).to be_nil
    end
  end
end
