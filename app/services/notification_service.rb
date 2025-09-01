class NotificationService
  # Create a notification and broadcast to recipient via ActionCable
  # params:
  # - recipient: User
  # - actor: model instance (optional)
  # - notifiable: model instance (optional)
  # - action: string describing action (e.g. 'donation_received')
  # - title, body: strings
  # - data: hash
  def self.notify(recipient: nil, recipients: nil, actor: nil, notifiable: nil, action: nil, title: nil, body: nil, data: {})
    payload = {
      actor_id: actor&.id,
      actor_type: actor&.class&.name,
      notifiable_id: notifiable&.id,
      notifiable_type: notifiable&.class&.name,
      action: action,
      title: title,
      body: body,
      data: data || {}
    }

    if recipients.present?
      recipient_ids = Array(recipients).map { |r| r.respond_to?(:id) ? r.id : r }
      # Enqueue a fanout job to handle bulk insert + broadcast
      NotificationFanoutJob.perform_later(recipient_ids, payload)
      return :enqueued
    end

    # Single recipient fast-path: create record and broadcast immediately
    if recipient.present?
      n = Notification.create!(
        recipient: recipient,
        actor: actor,
        notifiable: notifiable,
        action: action,
        title: title,
        body: body,
        data: data
      )

      # Maintain counter cache for single writes as well
      User.where(id: recipient.id).update_all("unread_notifications_count = COALESCE(unread_notifications_count, 0) + 1")

      payload_to_broadcast = {
        notification: {
          id: n.id,
          title: n.title,
          body: n.body,
          action: n.action,
          actor_type: n.actor_type,
          actor_id: n.actor_id,
          notifiable_type: n.notifiable_type,
          notifiable_id: n.notifiable_id,
          created_at: n.created_at.iso8601
        },
        unread_count: User.where(id: recipient.id).pick(:unread_notifications_count) || 0
      }

      NotificationsChannel.broadcast_to(recipient, payload_to_broadcast)
      return n
    end

    raise ArgumentError, "recipient or recipients required"
  end
end
