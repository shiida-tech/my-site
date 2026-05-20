class Inquiry < ApplicationRecord
  validates :name, presence: true, length: { maximum: 100 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, length: { maximum: 254 }
  validates :company_name, length: { maximum: 100 }, allow_blank: true
  validates :body, presence: true, length: { maximum: 2000 }
end
