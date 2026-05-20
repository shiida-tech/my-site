RSpec.describe "Pages", type: :request do
  describe "GET /" do
    it "200 を返す" do
      get root_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /privacy-policy" do
    it "200 を返す" do
      get privacy_policy_path
      expect(response).to have_http_status(:ok)
    end
  end
end
