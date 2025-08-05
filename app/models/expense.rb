class Expense < ApplicationRecord
  belongs_to :project

  validates :title, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true
  validates :project_id, presence: true
end
