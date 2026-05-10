RSpec.describe "管理画面 ダッシュボード", type: :request do
  let(:admin_user) { User.create!(email_address: "admin@test.com", password: "password", admin: true) }

  describe "GET /admin" do
    context "未ログイン時" do
      it "ログインページへリダイレクトする" do
        get admin_root_path
        expect(response).to redirect_to(new_session_path)
      end
    end

    context "管理者でログイン済み" do
      before { sign_in_as(admin_user, password: "password") }

      it "200を返す" do
        get admin_root_path
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
