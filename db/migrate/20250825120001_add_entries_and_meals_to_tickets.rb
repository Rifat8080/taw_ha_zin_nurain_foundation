class AddEntriesAndMealsToTickets < ActiveRecord::Migration[8.0]
  def change
    add_column :tickets, :entries_used, :integer, default: 0, null: false
    add_column :tickets, :max_entries, :integer, default: 1, null: false
    add_column :tickets, :meals_allowed, :integer, default: 0, null: false
    add_column :tickets, :meals_claimed, :integer, default: 0, null: false
    add_column :tickets, :on_break, :boolean, default: false, null: false
    add_column :tickets, :last_scanned_at, :datetime
    add_column :tickets, :break_started_at, :datetime
    add_column :tickets, :last_exit_at, :datetime
  end
end
