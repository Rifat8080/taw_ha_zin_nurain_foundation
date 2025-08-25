class AddScanActionsToTickets < ActiveRecord::Migration[8.0]
  def change
    add_column :tickets, :scan_actions, :jsonb, default: {}, null: false
    add_index :tickets, :scan_actions, using: :gin
  end
end
