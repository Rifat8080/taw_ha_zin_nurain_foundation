class HealthcareDonation < ApplicationRecord
  belongs_to :user
  belongs_to :healthcare_request, foreign_key: :request_id

  validates :amount, presence: true, numericality: { greater_than: 0 }

  scope :by_user, ->(user) { where(user: user) }
  scope :by_request, ->(request) { where(request_id: request.id) }
  scope :recent, -> { order(created_at: :desc) }
  scope :total_amount, -> { sum(:amount) }

  after_create :check_request_completion

  def donor_name
    user.full_name
  end

  def request_patient_name
    healthcare_request.patient_name
  end

  private

  def check_request_completion
    # You can add logic here to automatically mark requests as completed
    # based on donation goals or other criteria
  end
end
