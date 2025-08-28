class HealthcareRequest < ApplicationRecord
  belongs_to :user
  has_many :healthcare_donations, foreign_key: :request_id, dependent: :destroy do
    def sum_amount
      sum(:amount)
    end
  end
  has_many :healthcare_expenses, dependent: :destroy

  validates :patient_name, presence: true
  validates :reason, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending approved rejected completed] }
  validates :approved, inclusion: { in: [ true, false ] }

  # Counter cache columns
  attribute :donations_count, :integer, default: 0
  attribute :total_donations_cents, :integer, default: 0

  # Scopes for easy querying
  scope :approved_requests, -> { where(approved: true) }
  scope :pending_approval, -> { where(approved: false, status: "pending") }
  scope :by_status, ->(status) { where(status: status) }
  scope :visible_to_public, -> { where(approved: true, status: "approved") }
  scope :accepting_donations, -> { where(approved: true, status: "approved") }
  scope :search, ->(query) { where("patient_name ILIKE ? OR reason ILIKE ?", "%#{query}%", "%#{query}%") }

  # Optimized methods using counter caches
  def total_donations
    total_donations_cents.to_f / 100.0
  end

  def total_expenses
    healthcare_expenses.sum(:amount)
  end

  def balance
    total_donations - total_expenses
  end

  def donation_count
    donations_count
  end

  def expense_count
    healthcare_expenses.count
  end

  def approved?
    approved == true
  end

  def can_receive_donations?
    approved? && status == "approved"
  end

  def visible_to_public?
    approved? && status == "approved"
  end

  # Counter cache update method
  def update_counters
    update_columns(
      donations_count: healthcare_donations.count,
      total_donations_cents: (healthcare_donations.sum(:amount) * 100).to_i
    )
  end

  def mark_as_completed!
    update!(status: "completed")
  end

  def approve!
    update!(approved: true, status: "approved")
  end

  def reject!
    update!(approved: false, status: "rejected")
  end

  def formatted_total_donations
    "৳#{total_donations.to_f}"
  end

  def formatted_total_expenses
    "৳#{total_expenses.to_f}"
  end

  def formatted_balance
    balance_amount = balance
    sign = balance_amount >= 0 ? "+" : ""
    "#{sign}৳#{balance_amount.to_f}"
  end

  def balance_status
    case balance <=> 0
    when 1
      "surplus"
    when 0
      "balanced"
    when -1
      "deficit"
    end
  end
end
