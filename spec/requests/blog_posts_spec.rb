RSpec.describe "BlogPosts", type: :request do
  let!(:user) { User.create!(email_address: "admin@example.com", password: "password") }
  let!(:published_post) do
    BlogPost.create!(title: "公開記事", slug: "published-post", content: "本文", user: user,
                     status: :published, published_at: 1.day.ago)
  end
  let!(:draft_post) do
    BlogPost.create!(title: "下書き記事", slug: "draft-post", user: user)
  end

  describe "GET /blog" do
    it "未ログインでも 200 を返す" do
      get blog_posts_path
      expect(response).to have_http_status(:ok)
    end

    it "公開済み記事が body に含まれる" do
      get blog_posts_path
      expect(response.body).to include("公開記事")
    end

    it "下書き記事は body に含まれない" do
      get blog_posts_path
      expect(response.body).not_to include("下書き記事")
    end
  end

  describe "GET /blog/:id" do
    it "公開済み記事は 200 を返す" do
      get blog_post_path(published_post.slug)
      expect(response).to have_http_status(:ok)
    end

    it "公開済み記事のタイトルが body に含まれる" do
      get blog_post_path(published_post.slug)
      expect(response.body).to include("公開記事")
    end

    it "下書き記事は 404 を返す" do
      get blog_post_path(draft_post.slug)
      expect(response).to have_http_status(:not_found)
    end

    it "存在しない slug は 404 を返す" do
      get blog_post_path("not-exist")
      expect(response).to have_http_status(:not_found)
    end
  end
end
