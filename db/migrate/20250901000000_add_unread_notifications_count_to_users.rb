class AddUnreadNotificationsCountToUsers < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:users, :unread_notifications_count)
      add_column :users, :unread_notifications_count, :integer, default: 0, null: false
    end
  end
end
