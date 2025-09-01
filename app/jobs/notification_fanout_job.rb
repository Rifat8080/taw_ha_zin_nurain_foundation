class NotificationFanoutJob < ApplicationJob
  queue_as :notifications

  # recipients: array of User ids
  # payload: hash with notification fields (title, body, action, data, actor_id, actor_type, notifiable_id, notifiable_type)
  def perform(recipient_ids, payload)
    return if recipient_ids.blank?

    now = Time.current
    records = recipient_ids.map do |rid|
      {
        id: SecureRandom.uuid,
        recipient_id: rid,
        actor_id: payload[:actor_id],
        actor_type: payload[:actor_type],
        notifiable_id: payload[:notifiable_id],
        notifiable_type: payload[:notifiable_type],
        action: payload[:action],
        title: payload[:title],
        body: payload[:body],
        data: payload[:data] || {},
        created_at: now,
        updated_at: now
      }
    end

    # Use insert_all for bulk insert (atomic-ish and fast)
    Notification.insert_all(records)

    # Increment unread counter for recipients in a single query
    User.where(id: recipient_ids).update_all("unread_notifications_count = unread_notifications_count + 1")

    # Broadcast to each user via ActionCable with a small payload
    recipient_ids.each do |rid|
      payload_to_broadcast = {
        notification: {
          title: payload[:title],
          body: payload[:body],
          action: payload[:action],
          notifiable_type: payload[:notifiable_type],
          notifiable_id: payload[:notifiable_id],
          created_at: now.iso8601
        },
        unread_count: User.where(id: rid).pick(:unread_notifications_count) || 0
      }

      begin
        NotificationsChannel.broadcast_to(User.find(rid), payload_to_broadcast)
      rescue => e
        Rails.logger.error("NotificationFanoutJob broadcast error for user=#{rid}: #{e.message}")
      end
    end
  end
end
