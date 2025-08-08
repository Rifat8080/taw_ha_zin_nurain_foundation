class ZakatCalculation < ApplicationRecord
  belongs_to :user
  has_many :assets, dependent: :destroy
  has_many :liabilities, dependent: :destroy

  validates :calculation_year, presence: true, uniqueness: { scope: :user_id }
  validates :total_assets, :total_liabilities, :nisab_value, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :calculation_year, numericality: { greater_than: 1400, less_than_or_equal_to: -> { Date.current.year + 1 } }

  scope :for_year, ->(year) { where(calculation_year: year) }
  scope :recent, -> { order(calculation_year: :desc) }

  accepts_nested_attributes_for :assets, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :liabilities, allow_destroy: true, reject_if: :all_blank

  # Calculate totals from associated records
  def calculate_total_assets
    assets.sum(:amount)
  end

  def calculate_total_liabilities
    liabilities.sum(:amount)
  end

  # Update totals from associations
  def update_totals!
    update!(
      total_assets: calculate_total_assets,
      total_liabilities: calculate_total_liabilities
    )
  end

  # Get nisab value for the calculation year
  def current_nisab_rate
    @current_nisab_rate ||= NisabRate.find_by(year: calculation_year)
  end

  # Update nisab value based on current rates
  def update_nisab_value!
    rate = current_nisab_rate
    return unless rate

    # Use the lower of gold or silver nisab (more favorable for the payer)
    new_nisab = [ rate.nisab_gold, rate.nisab_silver ].min
    update!(nisab_value: new_nisab)
  end

  # Check if zakat is due
  def zakat_eligible?
    net_assets >= nisab_value
  end

  # Calculate zakat amount (2.5% of net assets if above nisab)
  def calculate_zakat_due
    return 0 unless zakat_eligible?
    (net_assets * 0.025).round(2)
  end

  # Get assets grouped by category
  def assets_by_category
    assets.group_by(&:category)
  end

  # Formatted display methods
  def formatted_net_assets
    ActionController::Base.helpers.number_to_currency(net_assets)
  end

  def formatted_zakat_due
    ActionController::Base.helpers.number_to_currency(zakat_due)
  end

  def formatted_nisab_value
    ActionController::Base.helpers.number_to_currency(nisab_value)
  end
end
