class Ticket < ApplicationRecord
  # Associations
  belongs_to :event
  belongs_to :user
  belongs_to :registered_by, class_name: "User", optional: true

  # Validations
  validates :qr_code, presence: true, uniqueness: true
  validates :ticket_type, presence: true, inclusion: { in: %w[general vip premium standard] }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true, inclusion: { in: %w[active used cancelled refunded] }
  validates :entries_used, numericality: { greater_than_or_equal_to: 0 }
  validates :max_entries, numericality: { greater_than_or_equal_to: 0 }
  validates :meals_allowed, numericality: { greater_than_or_equal_to: 0 }
  validates :meals_claimed, numericality: { greater_than_or_equal_to: 0 }
  validates :seat_number, uniqueness: { scope: :event_id, message: "is already taken for this event" }, allow_blank: true

  # Callbacks
  before_validation :generate_qr_code, on: :create
  before_validation :set_price_from_event, on: :create
  validate :ticket_type_availability, on: :create

  # Scopes
  scope :active, -> { where(status: "active") }
  scope :used, -> { where(status: "used") }
  scope :cancelled, -> { where(status: "cancelled") }
  scope :by_type, ->(type) { where(ticket_type: type) }

  # Instance methods
  def use_ticket!
    return false unless can_be_used?

    # Increment entries and mark used when entries exceed allowed
    new_entries = entries_used + 1
    attrs = { entries_used: new_entries, last_scanned_at: Time.current }

    if new_entries >= max_entries
      attrs[:status] = "used"
      attrs[:last_exit_at] = Time.current
    end

    update!(attrs)
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

  # Support re-entry: allow scan when entries_used < max_entries even if previously used
  def can_reenter?
    return false if status == "cancelled" || status == "refunded"
    entries_used < max_entries
  end

  def reenter!
    return false unless can_reenter?

    update!(entries_used: entries_used + 1, last_scanned_at: Time.current)
  end

  def claim_meal!
    return false if meals_claimed >= meals_allowed

    update!(meals_claimed: meals_claimed + 1)
  end

  def start_break!
    return false if on_break

    update!(on_break: true, break_started_at: Time.current)
  end

  def end_break!
    return false unless on_break

    update!(on_break: false, break_started_at: nil)
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

  # Track one-time scan actions per category
  def scanned_action?(action_name)
    return false unless self.respond_to?(:scan_actions)
    scan_actions && scan_actions[action_name.to_s] == true
  end

  def mark_scanned_action!(action_name)
    return false unless self.respond_to?(:scan_actions)
    self.scan_actions = (scan_actions || {}).merge(action_name.to_s => true)
    save!
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
    return if price.present? || event.nil? || ticket_type.blank?

    # Try to get price from ticket type configuration first
    if event.ticket_types.any?
      ticket_type_config = event.get_ticket_type(ticket_type)
      self.price = ticket_type_config&.dig("price") || event.ticket_price
  # Inherit meals_allowed from ticket type config if present, otherwise default to 1
  self.meals_allowed = (ticket_type_config&.dig("meals_allowed") || 1).to_i
    else
      # Fallback to legacy pricing
      self.price = event.ticket_price
  self.meals_allowed = 1
    end
  end

  def ticket_type_availability
    return unless event && ticket_type

    unless event.ticket_type_available?(ticket_type)
      errors.add(:ticket_type, "is sold out or not available")
    end
  end
end
