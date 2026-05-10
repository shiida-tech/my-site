RSpec.describe "セッション", type: :request do
  let!(:user) { User.create!(email_address: "admin@test.com", password: "password", admin: true) }

  describe "GET /session/new" do
    it "ログインフォームを表示する" do
      get new_session_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /session" do
    context "正しい認証情報の場合" do
      it "管理画面へリダイレクトする" do
        post session_path, params: { email_address: user.email_address, password: "password" }
        expect(response).to redirect_to(admin_root_path)
      end
    end

    context "誤った認証情報の場合" do
      it "ログインページへリダイレクトする" do
        post session_path, params: { email_address: user.email_address, password: "wrong" }
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "DELETE /session" do
    before { sign_in_as(user, password: "password") }

    it "トップページへリダイレクトする" do
      delete session_path
      expect(response).to redirect_to(root_path)
    end
  end
end
