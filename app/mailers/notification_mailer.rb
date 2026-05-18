class NotificationMailer < ApplicationMailer
  def sqlite_backup_failure(error)
    to = Rails.application.credentials.dig(:smtp, :user_name)
    mail(to: to, from: to, subject: "[my-site] SQLite バックアップ失敗", body: "#{error.class}: #{error.message}")
  end
end
