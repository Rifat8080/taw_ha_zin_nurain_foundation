class HealthcareExpense < ApplicationRecord
  belongs_to :healthcare_request
  belongs_to :user

  validates :description, presence: true, length: { minimum: 3, maximum: 255 }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :expense_date, presence: true
  validates :category, presence: true

  CATEGORIES = [
    "Medicine",
    "Doctor Consultation",
    "Hospital Charges",
    "Medical Tests",
    "Surgery",
    "Equipment",
    "Transportation",
    "Other"
  ].freeze

  validates :category, inclusion: { in: CATEGORIES }

  scope :by_category, ->(category) { where(category: category) }
  scope :by_date_range, ->(start_date, end_date) { where(expense_date: start_date..end_date) }
  scope :recent, -> { order(expense_date: :desc, created_at: :desc) }

  def formatted_amount
    "৳#{amount.to_f}"
  end
end
