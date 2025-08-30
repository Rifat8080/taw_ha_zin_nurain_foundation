class Notification < ApplicationRecord
  belongs_to :recipient, class_name: 'User'
  belongs_to :actor, polymorphic: true, optional: true
  belongs_to :notifiable, polymorphic: true, optional: true

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def mark_as_read!
    update!(read_at: Time.current) unless read_at
  end

  def unread?
    read_at.nil?
  end
end
