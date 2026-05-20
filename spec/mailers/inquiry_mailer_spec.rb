RSpec.describe InquiryMailer, type: :mailer do
  let(:inquiry) do
    Inquiry.create!(name: "山田太郎", email: "test@example.com",
                    company_name: "株式会社テスト", body: "お問い合わせ内容です。")
  end

  describe "#notification" do
    let(:mail) { described_class.notification(inquiry) }

    it "件名が正しい" do
      expect(mail.subject).to eq("[my-site] お問い合わせがありました")
    end

    it "本文に氏名が含まれる" do
      expect(mail.body.encoded).to include("山田太郎")
    end

    it "本文にメールアドレスが含まれる" do
      expect(mail.body.encoded).to include("test@example.com")
    end

    it "本文にお問い合わせ内容が含まれる" do
      expect(mail.body.encoded).to include("お問い合わせ内容です。")
    end

    it "本文に会社名が含まれる" do
      expect(mail.body.encoded).to include("株式会社テスト")
    end
  end
end
