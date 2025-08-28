class RevertDecimalsToIntegers < ActiveRecord::Migration[8.0]
  def change
    # Revert decimal amounts back to integers
    change_column :donations, :amount, :integer
    change_column :expenses, :amount, :integer
    change_column :payments, :amount, :integer
    change_column :events, :ticket_price, :integer
    change_column :tickets, :price, :integer
    change_column :healthcare_donations, :amount, :integer

    # Remove positive amount constraints since we're going back to integers
    remove_check_constraint :donations, name: "check_donations_amount_positive"
    remove_check_constraint :expenses, name: "check_expenses_amount_positive"
    remove_check_constraint :payments, name: "check_payments_amount_positive"
    remove_check_constraint :events, name: "check_events_ticket_price_positive"
    remove_check_constraint :tickets, name: "check_tickets_price_positive"
    remove_check_constraint :healthcare_donations, name: "check_healthcare_donations_amount_positive"
  end
end
