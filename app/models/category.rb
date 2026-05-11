class Category < ApplicationRecord
  has_many :blog_posts, dependent: :nullify

  validates :name, presence: true, uniqueness: true, length: { maximum: 50 }

  scope :ordered, -> { order(:name) }
end
