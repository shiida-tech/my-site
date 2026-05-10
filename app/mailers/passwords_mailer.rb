class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: "パスワードをリセットする", to: user.email_address
  end
end
