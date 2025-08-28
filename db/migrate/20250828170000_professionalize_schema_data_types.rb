class ProfessionalizeSchemaDataTypes < ActiveRecord::Migration[8.0]
  def change
    # Fix monetary amounts from integer to decimal with proper precision
    change_column :donations, :amount, :decimal, precision: 14, scale: 2
    change_column :expenses, :amount, :decimal, precision: 14, scale: 2
    change_column :payments, :amount, :decimal, precision: 14, scale: 2
    change_column :events, :ticket_price, :decimal, precision: 14, scale: 2
    change_column :tickets, :price, :decimal, precision: 14, scale: 2
    change_column :healthcare_donations, :amount, :decimal, precision: 14, scale: 2

  end
end
