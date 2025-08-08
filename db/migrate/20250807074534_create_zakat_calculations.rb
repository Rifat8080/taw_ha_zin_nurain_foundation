class CreateZakatCalculations < ActiveRecord::Migration[8.0]
  def change
    create_table :zakat_calculations, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.integer :calculation_year, null: false
      t.decimal :total_assets, precision: 14, scale: 2, default: 0
      t.decimal :total_liabilities, precision: 14, scale: 2, default: 0
      t.decimal :nisab_value, precision: 14, scale: 2, null: false

      t.timestamps
    end

    # Add computed columns using SQL
    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE zakat_calculations#{' '}
          ADD COLUMN net_assets DECIMAL(14,2) GENERATED ALWAYS AS (total_assets - total_liabilities) STORED;
        SQL

        execute <<-SQL
          ALTER TABLE zakat_calculations#{' '}
          ADD COLUMN zakat_due DECIMAL(14,2) GENERATED ALWAYS AS (
            CASE WHEN (total_assets - total_liabilities) >= nisab_value#{' '}
            THEN ROUND((total_assets - total_liabilities) * 0.025, 2)
            ELSE 0 END
          ) STORED;
        SQL
      end

      dir.down do
        execute "ALTER TABLE zakat_calculations DROP COLUMN net_assets;"
        execute "ALTER TABLE zakat_calculations DROP COLUMN zakat_due;"
      end
    end

    add_index :zakat_calculations, [ :user_id, :calculation_year ], unique: true
  end
end
