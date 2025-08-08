class CreateNisabRates < ActiveRecord::Migration[8.0]
  def change
    create_table :nisab_rates, id: :uuid do |t|
      t.integer :year, null: false
      t.decimal :gold_price_per_gram, precision: 8, scale: 2, null: false
      t.decimal :silver_price_per_gram, precision: 8, scale: 2, null: false

      t.timestamps
    end

    # Add computed columns using SQL
    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE nisab_rates#{' '}
          ADD COLUMN nisab_gold DECIMAL(14,2) GENERATED ALWAYS AS (gold_price_per_gram * 85) STORED;
        SQL

        execute <<-SQL
          ALTER TABLE nisab_rates#{' '}
          ADD COLUMN nisab_silver DECIMAL(14,2) GENERATED ALWAYS AS (silver_price_per_gram * 595) STORED;
        SQL
      end

      dir.down do
        execute "ALTER TABLE nisab_rates DROP COLUMN nisab_gold;"
        execute "ALTER TABLE nisab_rates DROP COLUMN nisab_silver;"
      end
    end

    add_index :nisab_rates, :year, unique: true
  end
end
