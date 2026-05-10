RSpec.describe "ログイン〜ダッシュボード", type: :system do
  let(:password) { "password" }
  let!(:user) { User.create!(email_address: "admin@example.com", password: password, admin: true) }

  it "ログインしてダッシュボードが表示される" do
    visit new_session_path

    fill_in "メールアドレス", with: user.email_address
    fill_in "パスワード", with: password
    click_button "ログイン"

    expect(page).to have_current_path(admin_root_path)
    expect(page).to have_text("ダッシュボード")
    expect(page).to have_text(user.email_address)
  end

  it "誤った認証情報ではログインできない" do
    visit new_session_path

    fill_in "メールアドレス", with: user.email_address
    fill_in "パスワード", with: "wrong"
    click_button "ログイン"

    expect(page).to have_current_path(new_session_path)
    expect(page).to have_text("メールアドレスまたはパスワードが正しくありません。")
  end

  it "ログアウトするとトップページへ戻る" do
    visit new_session_path
    fill_in "メールアドレス", with: user.email_address
    fill_in "パスワード", with: password
    click_button "ログイン"

    click_button "ログアウト"

    expect(page).to have_current_path(root_path)
  end
end
