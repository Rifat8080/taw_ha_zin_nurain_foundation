class ChangeUserColumnTypes < ActiveRecord::Migration[8.0]
  def change
    change_column :users, :first_name, :string
    change_column :users, :last_name, :string
    change_column :users, :email, :string
    change_column :users, :role, :string
    change_column :users, :address, :string
  end
end