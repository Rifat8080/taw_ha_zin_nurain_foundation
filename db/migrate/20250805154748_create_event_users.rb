class CreateEventUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :event_users, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :event, null: false, foreign_key: true, type: :uuid
      t.string :ticket_code, null: false
      t.string :status, default: "registered"

      t.timestamps
    end

    add_index :event_users, :ticket_code, unique: true
    add_index :event_users, :status
    add_index :event_users, [:user_id, :event_id], unique: true
  end
end
