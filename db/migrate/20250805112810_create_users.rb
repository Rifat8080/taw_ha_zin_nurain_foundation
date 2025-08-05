class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.text :first_name
      t.text :last_name
      t.integer :phone_number
      t.text :email
      t.text :password_digest
      t.text :role
      t.text :address

      t.timestamps
    end
  end
end
