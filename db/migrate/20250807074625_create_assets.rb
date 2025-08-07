class CreateAssets < ActiveRecord::Migration[8.0]
  def change
    create_table :assets, id: :uuid do |t|
      t.references :zakat_calculation, null: false, foreign_key: true, type: :uuid
      t.string :category, null: false
      t.text :description
      t.decimal :amount, precision: 14, scale: 2, null: false

      t.timestamps
    end

    # Add check constraint for category
    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE assets 
          ADD CONSTRAINT check_category 
          CHECK (category IN (
            'cash', 'bank', 'gold', 'silver', 'business_inventory', 
            'receivables', 'livestock', 'agriculture', 
            'investments', 'property_rent'
          ));
        SQL
        
        execute <<-SQL
          ALTER TABLE assets 
          ADD CONSTRAINT check_amount_positive 
          CHECK (amount >= 0);
        SQL
      end

      dir.down do
        execute "ALTER TABLE assets DROP CONSTRAINT check_category;"
        execute "ALTER TABLE assets DROP CONSTRAINT check_amount_positive;"
      end
    end

    add_index :assets, :category
  end
end
