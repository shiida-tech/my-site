RSpec.describe "パスワードリセット", type: :request do
  before { skip "パスワードリセットのルーティングを無効化中" }
  let!(:user) { User.create!(email_address: "admin@test.com", password: "password", admin: true) }

  describe "GET /passwords/new" do
    it "パスワードリセットフォームを表示する" do
      get new_password_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /passwords" do
    context "登録済みのメールアドレスの場合" do
      it "ログインページへリダイレクトする" do
        post passwords_path, params: { email_address: user.email_address }
        expect(response).to redirect_to(new_session_path)
      end

      it "パスワードリセットメールをエンキューする" do
        expect {
          post passwords_path, params: { email_address: user.email_address }
        }.to have_enqueued_mail(PasswordsMailer, :reset)
      end
    end

    context "未登録のメールアドレスの場合" do
      it "ログインページへリダイレクトする（存在確認を悟られないため）" do
        post passwords_path, params: { email_address: "unknown@example.com" }
        expect(response).to redirect_to(new_session_path)
      end

      it "メールをエンキューしない" do
        expect {
          post passwords_path, params: { email_address: "unknown@example.com" }
        }.not_to have_enqueued_mail(PasswordsMailer, :reset)
      end
    end
  end

  describe "GET /passwords/:token/edit" do
    context "有効なトークンの場合" do
      it "パスワード更新フォームを表示する" do
        token = user.password_reset_token
        get edit_password_path(token)
        expect(response).to have_http_status(:ok)
      end
    end

    context "無効なトークンの場合" do
      it "パスワードリセットフォームへリダイレクトする" do
        get edit_password_path("invalid_token")
        expect(response).to redirect_to(new_password_path)
      end
    end
  end

  describe "PUT /passwords/:token" do
    context "パスワードが一致する場合" do
      it "ログインページへリダイレクトする" do
        token = user.password_reset_token
        put password_path(token), params: { password: "newpassword", password_confirmation: "newpassword" }
        expect(response).to redirect_to(new_session_path)
      end
    end

    context "パスワードが一致しない場合" do
      it "パスワード更新フォームへリダイレクトする" do
        token = user.password_reset_token
        put password_path(token), params: { password: "newpassword", password_confirmation: "different" }
        expect(response).to redirect_to(edit_password_path(token))
      end
    end
  end
end
