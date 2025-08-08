class Event < ApplicationRecord
  # Associations
  has_many :event_users, dependent: :destroy
  has_many :users, through: :event_users
  has_many :tickets, dependent: :destroy
  has_many :guests, dependent: :destroy
  
  # Active Storage attachments
  has_one_attached :event_image
  has_one_attached :guest_image
  
  # Accept nested attributes for guests
  accepts_nested_attributes_for :guests, allow_destroy: true, reject_if: :all_blank
  
  # Validations
  validates :name, presence: true, length: { minimum: 3, maximum: 200 }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :seat_number, presence: true, numericality: { greater_than: 0 }
  validates :venue, presence: true, length: { minimum: 3, maximum: 500 }
  validates :ticket_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :ticket_category, presence: true, inclusion: { in: %w[general vip premium standard] }
  
  # Custom validations
  validate :end_date_after_start_date
  validate :end_time_after_start_time
  
  # Scopes
  scope :upcoming, -> { where('start_date >= ?', Date.current) }
  scope :past, -> { where('end_date < ?', Date.current) }
  scope :active, -> { where('start_date <= ? AND end_date >= ?', Date.current, Date.current) }
  scope :by_category, ->(category) { where(ticket_category: category) }
  
  # Instance methods
  def duration
    return 0 if start_date.nil? || end_date.nil?
    (end_date - start_date).to_i + 1
  end
  
  def available_seats
    seat_number - tickets.where(status: ['active', 'used']).count
  end
  
  def sold_out?
    available_seats <= 0
  end
  
  def event_status
    current_date = Date.current
    if current_date < start_date
      'upcoming'
    elsif current_date >= start_date && current_date <= end_date
      'active'
    else
      'past'
    end
  end
  
  private
  
  def end_date_after_start_date
    return unless start_date && end_date
    
    errors.add(:end_date, "must be after start date") if end_date < start_date
  end
  
  def end_time_after_start_time
    return unless start_time && end_time && start_date == end_date
    
    errors.add(:end_time, "must be after start time for same day events") if end_time <= start_time
  end
end
