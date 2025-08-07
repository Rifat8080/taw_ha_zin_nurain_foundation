class CreateHealthcareExpenses < ActiveRecord::Migration[8.0]
  def change
    create_table :healthcare_expenses, id: :uuid do |t|
      t.references :healthcare_request, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :description, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :category
      t.text :notes
      t.string :receipt_url
      t.date :expense_date, null: false

      t.timestamps
    end

    # Only add indexes if they don't exist
    add_index :healthcare_expenses, :healthcare_request_id unless index_exists?(:healthcare_expenses, :healthcare_request_id)
    add_index :healthcare_expenses, :user_id unless index_exists?(:healthcare_expenses, :user_id)
    add_index :healthcare_expenses, :expense_date unless index_exists?(:healthcare_expenses, :expense_date)
  end
end
