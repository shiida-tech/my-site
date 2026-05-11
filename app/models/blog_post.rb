class BlogPost < ApplicationRecord
  belongs_to :category, optional: true
  belongs_to :user
  has_rich_text :content

  enum :status, { draft: 0, published: 1 }

  validates :title, presence: true, length: { maximum: 255 }
  validates :slug, presence: true, uniqueness: true,
            format: { with: /\A[a-z0-9\-]+\z/, message: "は半角英小文字・数字・ハイフンのみ使用できます" }
  validates :content, presence: true, if: :published?

  before_validation :generate_slug, if: -> { slug.blank? && title.present? }

  scope :published_order, -> { published.where.not(published_at: nil).order(published_at: :desc) }
  scope :latest,          -> { published_order.limit(3) }

  def publish!
    update!(status: :published, published_at: published_at || Time.current)
  end

  def unpublish!
    update!(status: :draft)
  end

  private

  def generate_slug
    self.slug = SecureRandom.hex(4)
  end
end
