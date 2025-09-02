module NotificationsHelper
  # Resolve a notification to a safe path within the app.
  # Handles common notifiable types (Ticket, Event, Donation, HealthcareRequest, WorkOrder, Project)
  # and action-driven fallbacks.
  def notification_target_path(notification)
    return nil unless notification.present?

    notifiable = notification.notifiable
    action = notification.action.to_s

    # Prefer direct resource paths when a notifiable is present
    if notifiable.present?
      case notifiable.class.name
      when 'Ticket'
        return ticket_path(notifiable)
      when 'Event'
        return event_path(notifiable)
      when 'Donation'
        return donation_path(notifiable)
      when 'HealthcareRequest'
        return healthcare_request_path(notifiable)
      when 'WorkOrder'
        return work_order_path(notifiable)
      when 'Project'
        return project_path(notifiable)
      end
    end

    # Action based fallbacks (for notifications that reference actor/data instead)
    case action
    when 'ticket_purchased', 'ticket_purchase_confirmed', 'ticket_used'
      return tickets_path
    when 'donation_received', 'donation_created'
      return donations_path
    when 'registration_confirmed', 'spot_registration'
      return events_path
    when 'work_order_assigned', 'work_order_updated'
      return work_orders_path
    end

    # Last resort: notifications index
    notifications_path
  rescue => e
    Rails.logger.error("notification_target_path error: #{e.message}")
    nil
  end
end
