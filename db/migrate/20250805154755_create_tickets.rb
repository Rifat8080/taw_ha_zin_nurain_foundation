class CreateTickets < ActiveRecord::Migration[8.0]
  def change
    create_table :tickets, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :event, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :qr_code, null: false
      t.string :ticket_type, null: false
      t.integer :price, null: false
      t.string :status, default: "active"
      t.string :seat_number

      t.timestamps
    end

    add_index :tickets, :qr_code, unique: true
    add_index :tickets, :status
    add_index :tickets, :ticket_type
    add_index :tickets, [:event_id, :seat_number], unique: true
  end
end
