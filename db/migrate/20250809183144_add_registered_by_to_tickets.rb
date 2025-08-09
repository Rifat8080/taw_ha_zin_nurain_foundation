class AddRegisteredByToTickets < ActiveRecord::Migration[8.0]
  def change
    add_reference :tickets, :registered_by, foreign_key: { to_table: :users }, type: :uuid, null: true
  end
end
