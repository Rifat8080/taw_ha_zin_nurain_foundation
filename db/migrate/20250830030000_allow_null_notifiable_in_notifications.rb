class AllowNullNotifiableInNotifications < ActiveRecord::Migration[8.0]
  def change
    if column_exists?(:notifications, :notifiable_type)
      change_column_null :notifications, :notifiable_type, true
    end

    if column_exists?(:notifications, :notifiable_id)
      change_column_null :notifications, :notifiable_id, true
    end
  end
end
