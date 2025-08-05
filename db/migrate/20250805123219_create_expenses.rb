class CreateExpenses < ActiveRecord::Migration[8.0]
  def change
    create_table :expenses, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :title, null: false
      t.integer :amount, null: false
      t.date :date, null: false
      t.references :project, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
