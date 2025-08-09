class SpotRegistration
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :event_id, :string
  attribute :first_name, :string
  attribute :last_name, :string
  attribute :email, :string
  attribute :phone_number, :string
  attribute :address, :string
  attribute :ticket_type, :string
  attribute :quantity, :integer, default: 1

  validates :event_id, presence: true
  validates :first_name, presence: true, length: { minimum: 2 }
  validates :last_name, presence: true, length: { minimum: 2 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone_number, presence: true, length: { minimum: 10 }
  validates :ticket_type, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 10 }

  validate :event_exists
  validate :ticket_type_valid_for_event

  def event
    @event ||= Event.find_by(id: event_id) if event_id.present?
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end

  private

  def event_exists
    unless event.present?
      errors.add(:event_id, "must be a valid event")
    end
  end

  def ticket_type_valid_for_event
    return unless event.present? && ticket_type.present?

    if event.ticket_types.any?
      valid_types = event.available_ticket_types.map { |t| t['category'] }
      unless valid_types.include?(ticket_type)
        errors.add(:ticket_type, "is not available for this event")
      end
    else
      # Legacy event - allow general ticket type
      unless ['general', event.ticket_category].include?(ticket_type)
        errors.add(:ticket_type, "is not valid for this event")
      end
    end
  end
end
