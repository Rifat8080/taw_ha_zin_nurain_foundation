class CreateHealthcareDonations < ActiveRecord::Migration[8.0]
  def change
    create_table :healthcare_donations, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :user_id, null: false
      t.uuid :request_id, null: false
      t.integer :amount, null: false
      
      t.timestamps
      
      t.index :user_id
      t.index :request_id
      t.index :amount
    end
    
    add_foreign_key :healthcare_donations, :users
    add_foreign_key :healthcare_donations, :healthcare_requests, column: :request_id
  end
end
