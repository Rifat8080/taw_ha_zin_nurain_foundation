class EventNotificationJob < ApplicationJob
  queue_as :default

  def perform(event_id, action)
    event = Event.find_by(id: event_id)
    return unless event

    title = "Event #{action}: #{event.name}"
  body = action == "created" ? "A new event \"#{event.name}\" has been created for #{event.start_date}." : "Event \"#{event.name}\" was updated."

    # Notify admins and volunteers using batched fanout
    recipients = User.where(role: [ "admin", "volunteer" ]).pluck(:id)
    NotificationService.notify(
      recipients: recipients,
      actor: nil,
      notifiable: event,
      action: "event_#{action}",
      title: title,
      body: body,
      data: { event_id: event.id }
    )
  end
end
