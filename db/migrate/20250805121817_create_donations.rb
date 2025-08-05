class CreateDonations < ActiveRecord::Migration[8.0]
  def change
    create_table :donations, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.integer :amount
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :project, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
