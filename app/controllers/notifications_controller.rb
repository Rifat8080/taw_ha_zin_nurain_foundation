class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.recent.limit(50)
    respond_to do |format|
      format.html { render partial: "notifications/dropdown", locals: { notifications: @notifications } }
      format.json { render json: @notifications }
    end
  end

  def mark_as_read
    notification = current_user.notifications.find(params[:id])
    notification.mark_as_read!
  head :no_content
  end

  def mark_all_as_read
  Notification.mark_all_read_for(current_user)
  head :no_content
  end
end
