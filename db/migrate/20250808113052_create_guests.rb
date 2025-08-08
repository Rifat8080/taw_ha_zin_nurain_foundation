class CreateGuests < ActiveRecord::Migration[8.0]
  def change
    create_table :guests, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :name, null: false
      t.string :title
      t.text :description
      t.references :event, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
