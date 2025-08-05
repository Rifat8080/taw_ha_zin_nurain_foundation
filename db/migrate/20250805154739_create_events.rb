class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.text :name, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.integer :seat_number, null: false
      t.text :venue, null: false
      t.text :guest_list
      t.text :guest_description
      t.integer :ticket_price, null: false
      t.string :ticket_category, null: false

      t.timestamps
    end

    add_index :events, :start_date
    add_index :events, :ticket_category
  end
end
