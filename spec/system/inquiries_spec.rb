RSpec.describe "お問い合わせフォーム", type: :system do
  describe "フォーム送信フロー" do
    it "入力→送信→トップページへリダイレクト→フラッシュメッセージが表示される" do
      visit root_path
      click_link "お問い合わせ", match: :first

      fill_in "氏名", with: "山田太郎"
      fill_in "メールアドレス", with: "test@example.com"
      fill_in "お問い合わせ内容", with: "お問い合わせ内容のテストです。"
      click_button "送信する"

      expect(page).to have_current_path(root_path)
      expect(page).to have_text("お問い合わせを受け付けました。")
    end

    it "必須項目が未入力の場合はエラーが表示される" do
      visit new_inquiry_path

      click_button "送信する"

      expect(page).to have_current_path(inquiries_path)
      expect(page).to have_text("氏名 を入力してください")
    end
  end
end
