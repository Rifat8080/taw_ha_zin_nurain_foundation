class CreateLiabilities < ActiveRecord::Migration[8.0]
  def change
    create_table :liabilities, id: :uuid do |t|
      t.references :zakat_calculation, null: false, foreign_key: true, type: :uuid
      t.text :description
      t.decimal :amount, precision: 14, scale: 2, null: false

      t.timestamps
    end

    # Add check constraint for amount
    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE liabilities 
          ADD CONSTRAINT check_amount_positive 
          CHECK (amount >= 0);
        SQL
      end

      dir.down do
        execute "ALTER TABLE liabilities DROP CONSTRAINT check_amount_positive;"
      end
    end
  end
end
