class AddDescriptionToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :description, :text
  end
end
