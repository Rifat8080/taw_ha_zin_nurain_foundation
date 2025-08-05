class EventUser < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :event
  
  # Validations
  validates :ticket_code, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: %w[registered attended cancelled] }
  validates :user_id, uniqueness: { scope: :event_id, message: "is already registered for this event" }
  
  # Callbacks
  before_validation :generate_ticket_code, on: :create
  
  # Scopes
  scope :registered, -> { where(status: 'registered') }
  scope :attended, -> { where(status: 'attended') }
  scope :cancelled, -> { where(status: 'cancelled') }
  
  # Instance methods
  def mark_as_attended!
    update!(status: 'attended')
  end
  
  def cancel_registration!
    update!(status: 'cancelled')
  end
  
  def can_attend?
    status == 'registered' && event.event_status == 'active'
  end
  
  private
  
  def generate_ticket_code
    return if ticket_code.present?
    
    loop do
      self.ticket_code = SecureRandom.alphanumeric(10).upcase
      break unless EventUser.exists?(ticket_code: ticket_code)
    end
  end
end
