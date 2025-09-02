class AddManualFlagToHealthcareDonations < ActiveRecord::Migration[7.0]
  def change
    add_column :healthcare_donations, :manual, :boolean, default: false, null: false
    add_index :healthcare_donations, :manual
  end
end
