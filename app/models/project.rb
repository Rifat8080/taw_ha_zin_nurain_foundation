class Project < ApplicationRecord
    has_one_attached :image
    has_many :donations, dependent: :destroy
    has_many :expenses, dependent: :destroy

    validates :name, presence: true
    validates :description, presence: true
end
