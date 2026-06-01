class InquiriesController < ApplicationController
  def new
    @inquiry = Inquiry.new
  end

  def create
    if params.dig(:inquiry, :phone).present?
      redirect_to root_path, notice: "送信しました。"
      return
    end

    @inquiry = Inquiry.new(inquiry_params)

    unless verify_turnstile
      flash.now[:alert] = "認証に失敗しました。もう一度お試しください。"
      render :new, status: :unprocessable_content
      return
    end

    if @inquiry.save
      InquiryMailer.notification(@inquiry).deliver_later
      redirect_to root_path, notice: "お問い合わせを受け付けました。"
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def verify_turnstile
    return true unless Rails.env.production?

    token = params["cf-turnstile-response"]
    return false if token.blank?

    uri = URI("https://challenges.cloudflare.com/turnstile/v0/siteverify")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 3
    http.read_timeout = 3
    response = http.post(uri.path, URI.encode_www_form(
      "secret" => Rails.application.credentials.dig(:cloudflare, :turnstile_secret_key),
      "response" => token,
      "remoteip" => request.remote_ip
    ))
    result = JSON.parse(response.body)
    Rails.logger.warn("Turnstile 検証失敗: #{result['error-codes']}") unless result["success"]
    result["success"]
  rescue StandardError => e
    Rails.logger.error("Turnstile 検証エラー: #{e.class}: #{e.message}")
    true
  end

  def inquiry_params
    params.require(:inquiry).permit(:name, :email, :company_name, :body)
  end
end
