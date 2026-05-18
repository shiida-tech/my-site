# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

if Rails.env.development?
  admin_email    = ENV.fetch("ADMIN_EMAIL", "admin@example.com")
  admin_password = ENV.fetch("ADMIN_PASSWORD", "password1234")

  User.find_or_create_by!(email_address: admin_email) do |u|
    u.password = admin_password
    u.admin    = true
  end

  puts "管理者ユーザー準備完了: #{admin_email}"
end
