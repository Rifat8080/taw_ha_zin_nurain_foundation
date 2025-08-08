class Guest < ApplicationRecord
  belongs_to :event
  
  # Active Storage attachment for guest image
  has_one_attached :image
  
  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :title, length: { maximum: 150 }, allow_blank: true
  validates :description, length: { maximum: 1000 }, allow_blank: true
end
