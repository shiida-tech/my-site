RSpec.describe BlogPost, type: :model do
  let(:user) { User.create!(email_address: "test@example.com", password: "password") }

  describe "バリデーション" do
    it "title・slug・user があれば有効" do
      post = BlogPost.new(title: "Hello", slug: "hello", user: user)
      expect(post).to be_valid
    end

    it "title が空なら無効" do
      post = BlogPost.new(title: "", slug: "hello", user: user)
      expect(post).not_to be_valid
    end

    it "user がなければ無効" do
      post = BlogPost.new(title: "Hello", slug: "hello")
      expect(post).not_to be_valid
    end

    it "slug が重複なら無効" do
      BlogPost.create!(title: "First", slug: "same-slug", user: user)
      post = BlogPost.new(title: "Second", slug: "same-slug", user: user)
      expect(post).not_to be_valid
    end

    it "slug に日本語が含まれると無効" do
      post = BlogPost.new(title: "Test", slug: "テスト", user: user)
      expect(post).not_to be_valid
    end

    it "category は optional（nil でも有効）" do
      post = BlogPost.new(title: "Hello", slug: "hello", user: user, category: nil)
      expect(post).to be_valid
    end

    it "下書きのとき content が空でも有効" do
      post = BlogPost.new(title: "Hello", slug: "hello", user: user)
      expect(post).to be_valid
    end

    it "公開状態のとき content が空なら無効" do
      post = BlogPost.new(title: "Hello", slug: "hello", user: user, status: :published)
      expect(post).not_to be_valid
    end
  end

  describe "slug 自動生成" do
    it "slug が空のとき 8桁のランダム文字列で生成する" do
      post = BlogPost.new(title: "Hello World", user: user)
      post.valid?
      expect(post.slug).to match(/\A[a-f0-9]{8}\z/)
    end

    it "slug が指定済みなら自動生成しない" do
      post = BlogPost.new(title: "Hello", slug: "my-slug", user: user)
      post.valid?
      expect(post.slug).to eq("my-slug")
    end
  end

  describe "enum" do
    it "デフォルトのステータスは draft" do
      post = BlogPost.create!(title: "Hello", slug: "hello", user: user)
      expect(post).to be_draft
    end

    it "published? が正しく動く" do
      post = BlogPost.create!(title: "Hello", slug: "hello", content: "本文", user: user, status: :published, published_at: Time.current)
      expect(post).to be_published
    end
  end

  describe "スコープ" do
    before do
      BlogPost.create!(title: "Draft post", slug: "draft", user: user)
      BlogPost.create!(title: "Old post", slug: "old", content: "本文", user: user, status: :published, published_at: 2.days.ago)
      BlogPost.create!(title: "New post", slug: "new", content: "本文", user: user, status: :published, published_at: 1.day.ago)
    end

    it "published_order は published のみ published_at 降順で返す" do
      titles = BlogPost.published_order.map(&:title)
      expect(titles).to eq(["New post", "Old post"])
    end

    it "draft は published_order に含まれない" do
      titles = BlogPost.published_order.map(&:title)
      expect(titles).not_to include("Draft post")
    end

    it "latest は最大 3 件返す" do
      BlogPost.create!(title: "Extra", slug: "extra", content: "本文", user: user, status: :published, published_at: Time.current)
      expect(BlogPost.latest.count).to be <= 3
    end
  end

  describe "#publish!" do
    it "ステータスが published になる" do
      post = BlogPost.create!(title: "Hello", slug: "hello", content: "本文", user: user)
      post.publish!
      expect(post.reload).to be_published
    end

    it "published_at がセットされる" do
      post = BlogPost.create!(title: "Hello", slug: "hello", content: "本文", user: user)
      post.publish!
      expect(post.reload.published_at).not_to be_nil
    end

    it "すでに published_at がある場合は上書きしない" do
      original_time = 1.day.ago
      post = BlogPost.create!(title: "Hello", slug: "hello", content: "本文", user: user, status: :published, published_at: original_time)
      post.publish!
      expect(post.reload.published_at).to be_within(1.second).of(original_time)
    end
  end

  describe "#unpublish!" do
    it "ステータスが draft になる" do
      post = BlogPost.create!(title: "Hello", slug: "hello", content: "本文", user: user, status: :published, published_at: Time.current)
      post.unpublish!
      expect(post.reload).to be_draft
    end

    it "published_at は保持される" do
      published_at = 1.hour.ago
      post = BlogPost.create!(title: "Hello", slug: "hello", content: "本文", user: user, status: :published, published_at: published_at)
      post.unpublish!
      expect(post.reload.published_at).to be_within(1.second).of(published_at)
    end
  end
end
