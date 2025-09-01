class Notification < ApplicationRecord
  belongs_to :recipient, class_name: "User"
  belongs_to :actor, polymorphic: true, optional: true
  belongs_to :notifiable, polymorphic: true, optional: true

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def mark_as_read!
    return if read_at

    transaction do
      update!(read_at: Time.current)
      # decrement unread_notifications_count safely
      User.where(id: recipient_id).update_all("unread_notifications_count = GREATEST(COALESCE(unread_notifications_count, 0) - 1, 0)")
    end
  end

  def unread?
    read_at.nil?
  end

  # Bulk mark read for user and fix counter atomically-ish
  def self.mark_all_read_for(user)
    unread_count = where(recipient: user, read_at: nil).update_all(read_at: Time.current)
    # Set the user's counter to zero (best-effort)
    User.where(id: user.id).update_all(unread_notifications_count: 0)
    unread_count
  end
end
