class SetDefaultMealsAllowedOnTickets < ActiveRecord::Migration[8.0]
  def up
    # Change default to 1
    change_column_default :tickets, :meals_allowed, from: 0, to: 1

    # Backfill existing records where meals_allowed is 0 or NULL
    say_with_time "Backfilling meals_allowed for existing tickets" do
      Ticket.reset_column_information
      Ticket.where(meals_allowed: [nil, 0]).update_all(meals_allowed: 1)
    end
  end

  def down
    # Revert default to 0 (do not revert existing values)
    change_column_default :tickets, :meals_allowed, from: 1, to: 0
  end
end
