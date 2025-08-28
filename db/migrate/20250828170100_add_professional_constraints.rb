class AddProfessionalConstraints < ActiveRecord::Migration[8.0]
  def change
    # First, clean up invalid data
    execute "UPDATE events SET ticket_price = 1.00 WHERE ticket_price <= 0 OR ticket_price IS NULL"
    execute "UPDATE tickets SET price = 1.00 WHERE price <= 0 OR price IS NULL"
    execute "UPDATE donations SET amount = 1.00 WHERE amount <= 0 OR amount IS NULL"
    execute "UPDATE expenses SET amount = 1.00 WHERE amount <= 0 OR amount IS NULL"
    execute "UPDATE payments SET amount = 1.00 WHERE amount <= 0 OR amount IS NULL"
    execute "UPDATE healthcare_donations SET amount = 1.00 WHERE amount <= 0 OR amount IS NULL"

    # Add NOT NULL constraints for critical fields
    change_column_null :users, :email, false
    change_column_null :users, :first_name, false
    change_column_null :users, :last_name, false
    change_column_null :projects, :name, false

    # Add length limits for names
    change_column :users, :first_name, :string, limit: 50
    change_column :users, :last_name, :string, limit: 50
    change_column :projects, :name, :string, limit: 100

    # Add positive amount constraints
    add_check_constraint :donations, "amount > 0", name: "check_donations_amount_positive"
    add_check_constraint :expenses, "amount > 0", name: "check_expenses_amount_positive"
    add_check_constraint :payments, "amount > 0", name: "check_payments_amount_positive"
    add_check_constraint :events, "ticket_price > 0", name: "check_events_ticket_price_positive"
    add_check_constraint :tickets, "price > 0", name: "check_tickets_price_positive"
    add_check_constraint :healthcare_donations, "amount > 0", name: "check_healthcare_donations_amount_positive"

    # Add email format constraint
    add_check_constraint :users, "email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'", name: "check_users_email_format"
  end
end
