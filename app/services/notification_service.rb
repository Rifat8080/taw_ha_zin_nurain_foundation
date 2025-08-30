class NotificationService
  # Create a notification and broadcast to recipient via ActionCable
  # params:
  # - recipient: User
  # - actor: model instance (optional)
  # - notifiable: model instance (optional)
  # - action: string describing action (e.g. 'donation_received')
  # - title, body: strings
  # - data: hash
  def self.notify(recipient:, actor: nil, notifiable: nil, action: nil, title: nil, body: nil, data: {})
    n = Notification.create!(
      recipient: recipient,
      actor: actor,
      notifiable: notifiable,
      action: action,
      title: title,
      body: body,
      data: data
    )

    # Broadcast a JSON-only payload for client-side rendering (better at scale)
    payload = {
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
      unread_count: recipient.notifications.unread.count
    }

    NotificationsChannel.broadcast_to(recipient, payload)
    n
  end
end
