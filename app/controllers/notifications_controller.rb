class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.recent.limit(50)
    respond_to do |format|
      format.html { render partial: "notifications/dropdown", locals: { notifications: @notifications } }
      format.json { render json: @notifications }
    end
  end

  def unread_count
    # prefer counter column if present for performance, fallback to query
    count = if current_user.respond_to?(:unread_notifications_count) && current_user.unread_notifications_count.present?
      current_user.unread_notifications_count.to_i
    else
      current_user.notifications.unread.count
    end

    render json: { unread: count }
  end

  def mark_as_read
    notification = current_user.notifications.find(params[:id])
    notification.mark_as_read!
  head :no_content
  end

  def show
    notification = current_user.notifications.find(params[:id])
    # mark as read first
    notification.mark_as_read!

    # attempt to resolve a target path for the notification
    target = helpers.notification_target_path(notification)

    if target.present?
      redirect_to target
    else
      # fallback to notifications index
      redirect_to notifications_path
    end
  end

  def mark_all_as_read
  Notification.mark_all_read_for(current_user)
  head :no_content
  end
end
