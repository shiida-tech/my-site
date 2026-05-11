RSpec.describe "ブログ閲覧フロー", type: :system do
  let!(:user) { User.create!(email_address: "admin@example.com", password: "password") }
  let!(:category) { Category.create!(name: "Ruby") }
  let!(:post) do
    BlogPost.create!(
      title: "Railsの基礎",
      slug: "rails-basics",
      content: "Railsはとても楽しいフレームワークです。",
      category: category,
      user: user,
      status: :published,
      published_at: 1.day.ago
    )
  end

  it "トップページからブログ一覧を経由して記事詳細まで閲覧できる" do
    visit root_path

    # トップページのブログセクションに記事が表示される
    expect(page).to have_text("Railsの基礎")

    # 記事タイトルをクリックして詳細へ
    click_link "Railsの基礎"

    # 記事詳細ページが表示される
    expect(page).to have_text("Railsの基礎")
    expect(page).to have_text("Ruby")
    expect(page).to have_text("Railsはとても楽しいフレームワークです。")

    # ブログ一覧へ戻るリンクがある
    expect(page).to have_link("← ブログ一覧")
  end

  it "ブログ一覧から記事詳細へ遷移できる" do
    visit blog_posts_path

    expect(page).to have_text("Railsの基礎")
    expect(page).to have_text("Ruby")

    click_link "Railsの基礎"

    expect(page).to have_text("Railsの基礎")
    expect(page).to have_text("Railsはとても楽しいフレームワークです。")
  end
end
