class NisabRate < ApplicationRecord
  validates :year, presence: true, uniqueness: true
  validates :gold_price_per_gram, :silver_price_per_gram, presence: true, numericality: { greater_than: 0 }
  validates :year, numericality: { greater_than: 1400, less_than_or_equal_to: -> { Date.current.year + 1 } }

  scope :recent, -> { order(year: :desc) }
  scope :current_year, -> { where(year: Date.current.year) }

  # Get the current year's rate or the most recent one
  def self.current_rate
    current_year.first || recent.first
  end

  # Create or update rate for a year
  def self.set_rate_for_year(year, gold_price, silver_price)
    rate = find_or_initialize_by(year: year)
    rate.assign_attributes(
      gold_price_per_gram: gold_price,
      silver_price_per_gram: silver_price
    )
    rate.save!
    rate
  end

  # Formatted display methods
  def formatted_gold_price
    ActionController::Base.helpers.number_to_currency(gold_price_per_gram)
  end

  def formatted_silver_price
    ActionController::Base.helpers.number_to_currency(silver_price_per_gram)
  end

  def formatted_nisab_gold
    ActionController::Base.helpers.number_to_currency(nisab_gold)
  end

  def formatted_nisab_silver
    ActionController::Base.helpers.number_to_currency(nisab_silver)
  end

  # Get the lower nisab (more favorable for the payer)
  def min_nisab
    [ nisab_gold, nisab_silver ].min
  end

  def formatted_min_nisab
    ActionController::Base.helpers.number_to_currency(min_nisab)
  end

  # Check if this is the current year's rate
  def current_year?
    year == Date.current.year
  end
end
