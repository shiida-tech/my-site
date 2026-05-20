class InquiryMailer < ApplicationMailer
  def notification(inquiry)
    @inquiry = inquiry
    to = Rails.application.credentials.dig(:smtp, :user_name)
    mail(to: to, subject: "[my-site] お問い合わせがありました")
  end
end
