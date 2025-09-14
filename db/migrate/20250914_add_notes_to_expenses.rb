class AddNotesToExpenses < ActiveRecord::Migration[7.0]
  def change
    add_column :expenses, :notes, :text
  end
end
