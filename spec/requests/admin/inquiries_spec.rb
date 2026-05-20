RSpec.describe "Admin::Inquiries", type: :request do
  let(:password) { "password" }
  let!(:admin) { User.create!(email_address: "admin@example.com", password: password, admin: true) }
  let!(:non_admin) { User.create!(email_address: "user@example.com", password: password, admin: false) }
  let!(:inquiry) { Inquiry.create!(name: "山田太郎", email: "test@example.com", body: "こんにちは。") }

  describe "GET /admin/inquiries" do
    context "未ログインの場合" do
      it "ログインページへリダイレクトする" do
        get admin_inquiries_path
        expect(response).to redirect_to(new_session_path)
      end
    end

    context "非管理者の場合" do
      before { sign_in_as(non_admin, password: password) }

      it "root へリダイレクトする" do
        get admin_inquiries_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "管理者としてログイン済みの場合" do
      before { sign_in_as(admin, password: password) }

      it "200 を返す" do
        get admin_inquiries_path
        expect(response).to have_http_status(:ok)
      end

      it "お問い合わせ者名が body に含まれる" do
        get admin_inquiries_path
        expect(response.body).to include("山田太郎")
      end
    end
  end

  describe "GET /admin/inquiries/:id" do
    context "未ログインの場合" do
      it "ログインページへリダイレクトする" do
        get admin_inquiry_path(inquiry)
        expect(response).to redirect_to(new_session_path)
      end
    end

    context "管理者としてログイン済みの場合" do
      before { sign_in_as(admin, password: password) }

      it "200 を返す" do
        get admin_inquiry_path(inquiry)
        expect(response).to have_http_status(:ok)
      end

      it "アクセス時に既読になる" do
        expect(inquiry.read).to be false
        get admin_inquiry_path(inquiry)
        expect(inquiry.reload.read).to be true
      end

      it "お問い合わせ内容が body に含まれる" do
        get admin_inquiry_path(inquiry)
        expect(response.body).to include("こんにちは。")
      end
    end
  end
end
