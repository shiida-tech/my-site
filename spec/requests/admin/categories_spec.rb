RSpec.describe "Admin::Categories", type: :request do
  let(:password) { "password" }
  let!(:user) { User.create!(email_address: "admin@example.com", password: password, admin: true) }
  let!(:category) { Category.create!(name: "Ruby") }

  describe "GET /admin/categories" do
    context "未ログインの場合" do
      it "ログインページへリダイレクトする" do
        get admin_categories_path
        expect(response).to redirect_to(new_session_path)
      end
    end

    context "管理者としてログイン済みの場合" do
      before { sign_in_as(user, password: password) }

      it "200 を返す" do
        get admin_categories_path
        expect(response).to have_http_status(:ok)
      end

      it "カテゴリー名が body に含まれる" do
        get admin_categories_path
        expect(response.body).to include("Ruby")
      end
    end
  end

  describe "GET /admin/categories/new" do
    before { sign_in_as(user, password: password) }

    it "200 を返す" do
      get new_admin_category_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /admin/categories" do
    before { sign_in_as(user, password: password) }

    context "有効なパラメータの場合" do
      it "カテゴリーを作成して一覧にリダイレクトする" do
        expect {
          post admin_categories_path, params: { category: { name: "Rails" } }
        }.to change(Category, :count).by(1)
        expect(response).to redirect_to(admin_categories_path)
      end
    end

    context "無効なパラメータの場合" do
      it "422 を返す" do
        post admin_categories_path, params: { category: { name: "" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "GET /admin/categories/:id/edit" do
    before { sign_in_as(user, password: password) }

    it "200 を返す" do
      get edit_admin_category_path(category)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /admin/categories/:id" do
    before { sign_in_as(user, password: password) }

    context "有効なパラメータの場合" do
      it "更新して一覧にリダイレクトする" do
        patch admin_category_path(category), params: { category: { name: "Go" } }
        expect(response).to redirect_to(admin_categories_path)
        expect(category.reload.name).to eq("Go")
      end
    end

    context "無効なパラメータの場合" do
      it "422 を返す" do
        patch admin_category_path(category), params: { category: { name: "" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /admin/categories/:id" do
    before { sign_in_as(user, password: password) }

    it "削除して一覧にリダイレクトする" do
      expect {
        delete admin_category_path(category)
      }.to change(Category, :count).by(-1)
      expect(response).to redirect_to(admin_categories_path)
    end
  end
end
