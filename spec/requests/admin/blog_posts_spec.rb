RSpec.describe "Admin::BlogPosts", type: :request do
  let(:password) { "password" }
  let!(:user) { User.create!(email_address: "admin@example.com", password: password, admin: true) }
  let!(:blog_post) do
    BlogPost.create!(title: "テスト記事", slug: "test-post", content: "本文", user: user)
  end

  describe "GET /admin/blog_posts" do
    context "未ログインの場合" do
      it "ログインページへリダイレクトする" do
        get admin_blog_posts_path
        expect(response).to redirect_to(new_session_path)
      end
    end

    context "管理者としてログイン済みの場合" do
      before { sign_in_as(user, password: password) }

      it "200 を返す" do
        get admin_blog_posts_path
        expect(response).to have_http_status(:ok)
      end

      it "記事タイトルが body に含まれる" do
        get admin_blog_posts_path
        expect(response.body).to include("テスト記事")
      end
    end
  end

  describe "GET /admin/blog_posts/new" do
    before { sign_in_as(user, password: password) }

    it "200 を返す" do
      get new_admin_blog_post_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /admin/blog_posts" do
    before { sign_in_as(user, password: password) }

    context "有効なパラメータの場合" do
      it "記事を作成して詳細にリダイレクトする" do
        expect {
          post admin_blog_posts_path, params: {
            blog_post: { title: "新しい記事", slug: "new-post" }
          }
        }.to change(BlogPost, :count).by(1)
        expect(response).to redirect_to(admin_blog_post_path(BlogPost.last))
      end

      it "ステータスは draft になる" do
        post admin_blog_posts_path, params: {
          blog_post: { title: "新しい記事", slug: "new-post" }
        }
        expect(BlogPost.last).to be_draft
      end
    end

    context "無効なパラメータの場合" do
      it "422 を返す" do
        post admin_blog_posts_path, params: {
          blog_post: { title: "", slug: "new-post" }
        }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "GET /admin/blog_posts/:id" do
    before { sign_in_as(user, password: password) }

    it "200 を返す" do
      get admin_blog_post_path(blog_post)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /admin/blog_posts/:id/edit" do
    before { sign_in_as(user, password: password) }

    it "200 を返す" do
      get edit_admin_blog_post_path(blog_post)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /admin/blog_posts/:id" do
    before { sign_in_as(user, password: password) }

    context "有効なパラメータの場合" do
      it "記事を更新して詳細にリダイレクトする" do
        patch admin_blog_post_path(blog_post), params: {
          blog_post: { title: "更新タイトル" }
        }
        expect(response).to redirect_to(admin_blog_post_path(blog_post))
        expect(blog_post.reload.title).to eq("更新タイトル")
      end
    end

    context "無効なパラメータの場合" do
      it "422 を返す" do
        patch admin_blog_post_path(blog_post), params: {
          blog_post: { title: "" }
        }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /admin/blog_posts/:id" do
    before { sign_in_as(user, password: password) }

    it "記事を削除して一覧にリダイレクトする" do
      expect {
        delete admin_blog_post_path(blog_post)
      }.to change(BlogPost, :count).by(-1)
      expect(response).to redirect_to(admin_blog_posts_path)
    end
  end

  describe "POST /admin/blog_posts/:id/publish" do
    before { sign_in_as(user, password: password) }

    it "ステータスが published になる" do
      post publish_admin_blog_post_path(blog_post)
      expect(blog_post.reload).to be_published
    end

    it "published_at がセットされる" do
      post publish_admin_blog_post_path(blog_post)
      expect(blog_post.reload.published_at).not_to be_nil
    end

    it "詳細ページにリダイレクトする" do
      post publish_admin_blog_post_path(blog_post)
      expect(response).to redirect_to(admin_blog_post_path(blog_post))
    end
  end

  describe "POST /admin/blog_posts/:id/unpublish" do
    let!(:published_post) do
      BlogPost.create!(title: "公開記事", slug: "published", content: "本文", user: user,
                       status: :published, published_at: Time.current)
    end
    before { sign_in_as(user, password: password) }

    it "ステータスが draft になる" do
      post unpublish_admin_blog_post_path(published_post)
      expect(published_post.reload).to be_draft
    end

    it "詳細ページにリダイレクトする" do
      post unpublish_admin_blog_post_path(published_post)
      expect(response).to redirect_to(admin_blog_post_path(published_post))
    end
  end

  describe "GET /admin/blog_posts/:id/preview" do
    context "未ログインの場合" do
      it "ログインページへリダイレクトする" do
        get preview_admin_blog_post_path(blog_post)
        expect(response).to redirect_to(new_session_path)
      end
    end

    context "管理者としてログイン済みの場合" do
      before { sign_in_as(user, password: password) }

      it "200 を返す" do
        get preview_admin_blog_post_path(blog_post)
        expect(response).to have_http_status(:ok)
      end

      it "プレビューバナーが body に含まれる" do
        get preview_admin_blog_post_path(blog_post)
        expect(response.body).to include("プレビュー表示中です")
      end

      it "下書き記事もプレビューできる" do
        expect(blog_post).to be_draft
        get preview_admin_blog_post_path(blog_post)
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
