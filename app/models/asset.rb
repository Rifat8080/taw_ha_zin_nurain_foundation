class Asset < ApplicationRecord
  belongs_to :zakat_calculation

  CATEGORIES = [
    'cash', 'bank', 'gold', 'silver', 'business_inventory',
    'receivables', 'livestock', 'agriculture',
    'investments', 'property_rent'
  ].freeze

  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :description, length: { maximum: 500 }

  scope :by_category, ->(category) { where(category: category) }
  scope :valuable, -> { where('amount > 0') }

  after_save :update_calculation_totals
  after_destroy :update_calculation_totals

  # Category display methods
  def self.category_options
    CATEGORIES.map { |cat| [cat.humanize, cat] }
  end

  def category_display
    case category
    when 'cash' then 'Cash on Hand'
    when 'bank' then 'Bank Accounts'
    when 'gold' then 'Gold'
    when 'silver' then 'Silver'
    when 'business_inventory' then 'Business Inventory'
    when 'receivables' then 'Accounts Receivable'
    when 'livestock' then 'Livestock'
    when 'agriculture' then 'Agricultural Products'
    when 'investments' then 'Investments'
    when 'property_rent' then 'Rental Property Income'
    else category.humanize
    end
  end

  # Formatted display methods
  def formatted_amount
    ActionController::Base.helpers.number_to_currency(amount)
  end

  def display_description
    description.presence || "#{category_display} asset"
  end

  private

  def update_calculation_totals
    zakat_calculation.update_totals! if zakat_calculation
  end
end
