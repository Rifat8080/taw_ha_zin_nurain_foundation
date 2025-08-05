class CreateWorkOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :work_orders, id: :uuid do |t|
      t.uuid :team_id, null: false
      t.text :title, null: false
      t.text :description, null: false
      t.text :checklist, null: false
      t.date :assigned_date, null: false
      t.uuid :assigned_by, null: false

      t.timestamps
    end

    add_foreign_key :work_orders, :volunteers_teams, column: :team_id
    add_foreign_key :work_orders, :users, column: :assigned_by
    add_index :work_orders, :team_id
    add_index :work_orders, :assigned_by
  end
end
