class FixActorOnNotifications < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:notifications, :actor_type)
      add_column :notifications, :actor_type, :string
    end

    # Allow actor_id to be null so notifications can be system-generated
    if column_exists?(:notifications, :actor_id)
      change_column_null :notifications, :actor_id, true
    end
  end
end
