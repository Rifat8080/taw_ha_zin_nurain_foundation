
class Blog < ApplicationRecord
  has_many_attached :images

  validates :title, :body, :author, presence: true
  validates :title, length: { maximum: 200 }

  scope :published, -> { where.not(published_at: nil).order(published_at: :desc) }
end
