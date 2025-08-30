class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
  # If the table already exists (e.g., manual/previous setup), skip creation
  return if table_exists?(:notifications)

  create_table :notifications do |t|
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.string :actor_type
      t.bigint :actor_id
      t.string :notifiable_type
      t.bigint :notifiable_id
      t.string :action
      t.string :title
      t.text :body
      t.jsonb :data, default: {}
      t.datetime :read_at
      t.timestamps
    end

  add_index :notifications, [:recipient_id, :read_at]
  end
end
