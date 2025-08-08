class Liability < ApplicationRecord
  belongs_to :zakat_calculation

  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :description, presence: true, length: { maximum: 500 }

  scope :valuable, -> { where("amount > 0") }

  after_save :update_calculation_totals
  after_destroy :update_calculation_totals

  # Formatted display methods
  def formatted_amount
    ActionController::Base.helpers.number_to_currency(amount)
  end

  def display_description
    description.presence || "Liability"
  end

  private

  def update_calculation_totals
    zakat_calculation.update_totals! if zakat_calculation
  end
end
