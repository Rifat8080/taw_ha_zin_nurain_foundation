class AddFieldsToNotifications < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:notifications, :title)
      add_column :notifications, :title, :string
    end

    unless column_exists?(:notifications, :body)
      add_column :notifications, :body, :text
    end

    unless column_exists?(:notifications, :data)
      add_column :notifications, :data, :jsonb, default: {}
    end
  end
end
