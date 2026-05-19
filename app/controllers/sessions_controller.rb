class SessionsController < ApplicationController
  include Authentication
  before_action :http_authenticate, only: %i[new create], if: -> { Rails.env.production? }
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "しばらく時間をおいてから再試行してください。" }

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "メールアドレスまたはパスワードが正しくありません。"
    end
  end

  def destroy
    terminate_session
    redirect_to root_path, status: :see_other
  end

  private

  def http_authenticate
    authenticate_or_request_with_http_basic do |name, password|
      expected_name = Rails.application.credentials.dig(:http_basic_auth, :name).to_s
      expected_password = Rails.application.credentials.dig(:http_basic_auth, :password).to_s
      return false if expected_name.empty? || expected_password.empty?

      ActiveSupport::SecurityUtils.secure_compare(name, expected_name) &
        ActiveSupport::SecurityUtils.secure_compare(password, expected_password)
    end
  end
end
