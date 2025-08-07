class HealthcareRequest < ApplicationRecord
  belongs_to :user
  has_many :healthcare_donations, foreign_key: :request_id, dependent: :destroy
  
  validates :patient_name, presence: true
  validates :reason, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending approved rejected completed] }
  validates :approved, inclusion: { in: [true, false] }
  
  # Scopes for easy querying
  scope :approved_requests, -> { where(approved: true) }
  scope :pending_approval, -> { where(approved: false, status: 'pending') }
  scope :by_status, ->(status) { where(status: status) }
  
  def total_donations
    healthcare_donations.sum(:amount)
  end
  
  def donation_count
    healthcare_donations.count
  end
  
  def approved?
    approved == true
  end
  
  def can_receive_donations?
    approved? && (status == 'approved' || status == 'pending')
  end
  
  def mark_as_completed!
    update!(status: 'completed')
  end
  
  def approve!
    update!(approved: true, status: 'approved')
  end
  
  def reject!
    update!(approved: false, status: 'rejected')
  end
end
