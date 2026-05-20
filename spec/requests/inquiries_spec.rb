RSpec.describe "Inquiries", type: :request do
  describe "GET /inquiries/new" do
    it "200 を返す" do
      get new_inquiry_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /inquiries" do
    let(:valid_params) do
      { inquiry: { name: "山田太郎", email: "test@example.com", body: "お問い合わせ内容", phone: "" } }
    end

    context "有効なパラメータの場合" do
      it "お問い合わせを保存してトップページへリダイレクトする" do
        expect {
          post inquiries_path, params: valid_params
        }.to change(Inquiry, :count).by(1)
        expect(response).to redirect_to(root_path)
      end
    end

    context "無効なパラメータの場合" do
      it "422 を返す" do
        post inquiries_path, params: { inquiry: { name: "", email: "", body: "", phone: "" } }
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "お問い合わせを保存しない" do
        expect {
          post inquiries_path, params: { inquiry: { name: "", email: "", body: "", phone: "" } }
        }.not_to change(Inquiry, :count)
      end
    end

    context "ハニーポットが入力されている場合" do
      it "お問い合わせを保存せずにリダイレクトする" do
        expect {
          post inquiries_path, params: { inquiry: { name: "スパム", email: "spam@example.com", body: "スパム", phone: "090-0000-0000" } }
        }.not_to change(Inquiry, :count)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
