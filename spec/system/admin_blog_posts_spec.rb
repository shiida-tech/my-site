RSpec.describe "管理画面 ブログ記事", type: :system do
  let(:password) { "password" }
  let!(:user) { User.create!(email_address: "admin@example.com", password: password, admin: true) }

  def login
    visit new_session_path
    fill_in "メールアドレス", with: user.email_address
    fill_in "パスワード", with: password
    click_button "ログイン"
  end

  describe "記事一覧" do
    it "ブログ記事一覧ページにアクセスできる" do
      login
      visit admin_blog_posts_path
      expect(page).to have_text("ブログ記事")
    end

    it "記事がない場合はメッセージが表示される" do
      login
      visit admin_blog_posts_path
      expect(page).to have_text("記事がまだありません")
    end

    it "作成した記事が一覧に表示される" do
      BlogPost.create!(title: "一覧テスト記事", slug: "list-test", user: user)
      login
      visit admin_blog_posts_path
      expect(page).to have_text("一覧テスト記事")
    end
  end

  describe "記事作成" do
    before { login }

    it "新規作成フォームにアクセスできる" do
      visit new_admin_blog_post_path
      expect(page).to have_text("記事作成")
    end

    it "タイトルを入力して下書き保存できる" do
      visit new_admin_blog_post_path
      fill_in "タイトル", with: "システムテスト記事"
      fill_in "スラッグ（URL）", with: "system-test-post"
      click_button "下書き保存"
      expect(page).to have_text("記事を作成しました")
      expect(page).to have_text("システムテスト記事")
    end

    it "タイトルが空の場合はエラーメッセージが表示される" do
      visit new_admin_blog_post_path
      fill_in "スラッグ（URL）", with: "some-slug"
      click_button "下書き保存"
      expect(page).to have_text("タイトル を入力してください")
    end
  end

  describe "ステータス操作" do
    let!(:draft_post) { BlogPost.create!(title: "下書き記事", slug: "draft", content: "本文", user: user) }
    let!(:published_post) do
      BlogPost.create!(title: "公開記事", slug: "published", content: "本文", user: user,
                       status: :published, published_at: Time.current)
    end
    before { login }

    it "「公開する」ボタンで記事が公開状態になる" do
      visit admin_blog_post_path(draft_post)
      click_button "公開する"
      expect(page).to have_text("記事を公開しました")
      expect(draft_post.reload).to be_published
    end

    it "「非公開にする」ボタンで記事が下書き状態になる" do
      visit admin_blog_post_path(published_post)
      click_button "非公開にする"
      expect(page).to have_text("記事を非公開にしました")
      expect(published_post.reload).to be_draft
    end

    it "公開中バッジが表示される" do
      visit admin_blog_posts_path
      expect(page).to have_text("公開中")
    end

    it "下書きバッジが表示される" do
      visit admin_blog_posts_path
      expect(page).to have_text("下書き")
    end
  end

  describe "プレビュー" do
    let!(:post) { BlogPost.create!(title: "プレビューテスト", slug: "preview-test", content: "本文", user: user) }
    before { login }

    it "プレビューボタンをクリックするとプレビューバナーが表示される" do
      visit admin_blog_post_path(post)
      click_link "プレビュー"
      expect(page).to have_text("プレビュー表示中")
      expect(page).to have_text("プレビューテスト")
    end
  end

  describe "カテゴリー連携" do
    let!(:category) { Category.create!(name: "Ruby") }
    before { login }

    it "カテゴリー選択ドロップダウンが表示される" do
      visit new_admin_blog_post_path
      expect(page).to have_select("カテゴリー", with_options: [ "Ruby" ])
    end

    it "カテゴリーを選択して保存できる" do
      visit new_admin_blog_post_path
      fill_in "タイトル", with: "カテゴリーテスト"
      fill_in "スラッグ（URL）", with: "category-test"
      select "Ruby", from: "カテゴリー"
      click_button "下書き保存"
      expect(page).to have_text("記事を作成しました")
      expect(BlogPost.last.category).to eq(category)
    end
  end
end
