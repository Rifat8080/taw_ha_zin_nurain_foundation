class Event < ApplicationRecord
  # Associations
  has_many :event_users, dependent: :destroy
  has_many :users, through: :event_users
  has_many :tickets, dependent: :destroy
  has_many :guests, dependent: :destroy

  # Active Storage attachments
  has_one_attached :event_image

  # Accept nested attributes for guests
  accepts_nested_attributes_for :guests, allow_destroy: true, reject_if: proc { |attributes|
    attributes["name"].blank? && attributes["title"].blank? && attributes["description"].blank? && attributes["image"].blank?
  }

  # Validations
  validates :name, presence: true, length: { minimum: 3, maximum: 200 }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :venue, presence: true, length: { minimum: 3, maximum: 500 }

  # Ticket types validation
  validate :ticket_types_config_format
  validate :at_least_one_ticket_type

  # Legacy field validations (for backward compatibility)
  validates :total_seats, presence: true, numericality: { greater_than: 0 }, if: :legacy_mode?
  validates :ticket_price, presence: true, numericality: { greater_than_or_equal_to: 0 }, if: :legacy_mode?
  validates :ticket_category, presence: true, inclusion: { in: %w[general vip premium standard] }, if: :legacy_mode?

  # Custom validations
  validate :end_date_after_start_date
  validate :end_time_after_start_time

  # Scopes
  scope :upcoming, -> { where("start_date >= ?", Date.current) }
  scope :past, -> { where("end_date < ?", Date.current) }
  scope :active, -> { where("start_date <= ? AND end_date >= ?", Date.current, Date.current) }
  scope :by_category, ->(category) { where(ticket_category: category) }

  # Ticket Types Methods
  def ticket_types
    @ticket_types ||= (ticket_types_config || []).map(&:with_indifferent_access)
  end

  def ticket_types=(types_array)
    self.ticket_types_config = types_array.map do |type|
      {
        name: type[:name],
        category: type[:category],
        price: type[:price].to_f,
        seats_available: type[:seats_available].to_i,
        description: type[:description]
      }
    end
  end

  def available_ticket_types
    ticket_types.map do |type|
      sold_count = tickets.where(ticket_type: type["category"], status: [ "active", "used" ]).count
      type.merge(
        "seats_sold" => sold_count,
        "seats_remaining" => [ type["seats_available"] - sold_count, 0 ].max,
        "sold_out" => (type["seats_available"] - sold_count) <= 0
      )
    end
  end

  def get_ticket_type(category)
    ticket_types.find { |type| type["category"] == category }
  end

  def ticket_type_available?(category, quantity = 1)
    type_info = available_ticket_types.find { |type| type["category"] == category }
    return false unless type_info
    type_info["seats_remaining"] >= quantity
  end

  def total_seats_available
    ticket_types.sum { |type| type["seats_available"] }
  end

  def total_seats_sold
    available_ticket_types.sum { |type| type["seats_sold"] }
  end

  def total_seats_remaining
    total_seats_available - total_seats_sold
  end

  # Legacy support methods
  def legacy_mode?
    ticket_types_config.blank? || ticket_types_config == []
  end

  # Instance methods
  def duration
    return 0 if start_date.nil? || end_date.nil?
    (end_date - start_date).to_i + 1
  end

  def available_seats
    if legacy_mode?
      total_seats - tickets.where(status: [ "active", "used" ]).count
    else
      total_seats_remaining
    end
  end

  def sold_out?
    if legacy_mode?
      available_seats <= 0
    else
      available_ticket_types.all? { |type| type["sold_out"] }
    end
  end

  def event_status
    current_date = Date.current
    if current_date < start_date
      "upcoming"
    elsif current_date >= start_date && current_date <= end_date
      "active"
    else
      "past"
    end
  end

  # Notify admins and volunteers when events are created or updated.
  after_commit :notify_event_created, on: :create
  after_commit :notify_event_updated, on: :update

  def notify_event_created
    EventNotificationJob.perform_later(id, 'created')
  end

  def notify_event_updated
    EventNotificationJob.perform_later(id, 'updated')
  end

  private

  def ticket_types_config_format
    return if ticket_types_config.blank?

    unless ticket_types_config.is_a?(Array)
      errors.add(:ticket_types_config, "must be an array")
      return
    end

    ticket_types_config.each_with_index do |type, index|
      unless type.is_a?(Hash)
        errors.add(:ticket_types_config, "each ticket type must be a hash")
        next
      end

      required_fields = %w[name category price seats_available]
      required_fields.each do |field|
        if type[field].blank?
          errors.add(:ticket_types_config, "ticket type #{index + 1} is missing #{field}")
        end
      end

      if type["price"].present? && type["price"].to_f < 0
        errors.add(:ticket_types_config, "ticket type #{index + 1} price must be non-negative")
      end

      if type["seats_available"].present? && type["seats_available"].to_i <= 0
        errors.add(:ticket_types_config, "ticket type #{index + 1} must have at least 1 seat available")
      end
    end
  end

  def at_least_one_ticket_type
    if !legacy_mode? && ticket_types_config.blank?
      errors.add(:ticket_types_config, "must have at least one ticket type")
    end
  end

  def end_date_after_start_date
    return unless start_date && end_date

    errors.add(:end_date, "must be after start date") if end_date < start_date
  end

  def end_time_after_start_time
    return unless start_time && end_time && start_date == end_date

    errors.add(:end_time, "must be after start time for same day events") if end_time <= start_time
  end
end
