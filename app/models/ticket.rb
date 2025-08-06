class Ticket < ApplicationRecord
  # Associations
  belongs_to :event
  belongs_to :user

  # Validations
  validates :qr_code, presence: true, uniqueness: true
  validates :ticket_type, presence: true, inclusion: { in: %w[general vip premium standard] }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true, inclusion: { in: %w[active used cancelled refunded] }
  validates :seat_number, uniqueness: { scope: :event_id, message: "is already taken for this event" }, allow_blank: true

  # Callbacks
  before_validation :generate_qr_code, on: :create
  before_validation :set_price_from_event, on: :create

  # Scopes
  scope :active, -> { where(status: "active") }
  scope :used, -> { where(status: "used") }
  scope :cancelled, -> { where(status: "cancelled") }
  scope :by_type, ->(type) { where(ticket_type: type) }

  # Instance methods
  def use_ticket!
    return false unless can_be_used?
    update!(status: "used")
  end

  def cancel_ticket!
    return false unless can_be_cancelled?
    update!(status: "cancelled")
  end

  def refund_ticket!
    return false unless can_be_refunded?
    update!(status: "refunded")
  end

  def can_be_used?
    return false unless status == "active"

    # Allow ticket usage on the event day or when event is active
    current_date = Date.current
    event_start = event.start_date
    event_end = event.end_date

    # Ticket can be used if:
    # 1. Current date is on or between event dates, OR
    # 2. Current date is within 1 day of the event start (for early check-ins)
    (current_date >= event_start && current_date <= event_end) ||
    (current_date >= event_start.advance(days: -1) && current_date <= event_start)
  end

  def can_be_cancelled?
    status == "active" && event.start_date > Date.current
  end

  def can_be_refunded?
    status == "active" && event.start_date > Date.current.advance(days: 1)
  end

  def qr_code_data
    {
      ticket_id: id,
      event_id: event_id,
      user_id: user_id,
      qr_code: qr_code,
      ticket_type: ticket_type,
      seat_number: seat_number,
      event_name: event.name,
      user_name: "#{user.first_name} #{user.last_name}",
      created_at: created_at.iso8601
    }.to_json
  end

  def qr_code_svg
    QrCodeService.generate_svg_for_ticket(self)
  end

  private

  def generate_qr_code
    return if qr_code.present?

    loop do
      self.qr_code = SecureRandom.hex(16).upcase
      break unless Ticket.exists?(qr_code: qr_code)
    end
  end

  def set_price_from_event
    return if price.present? || event.nil?
    self.price = event.ticket_price
  end
end
