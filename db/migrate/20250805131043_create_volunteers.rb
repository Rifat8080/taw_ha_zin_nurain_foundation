class CreateVolunteers < ActiveRecord::Migration[8.0]
  def change
    create_table :volunteers, id: :uuid do |t|
      t.uuid :user_id, null: false
      t.date :joining_date, null: false
      t.string :role, null: false

      t.timestamps
    end

    add_foreign_key :volunteers, :users
    add_index :volunteers, :user_id
  end
end
