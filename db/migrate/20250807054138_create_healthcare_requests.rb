class CreateHealthcareRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :healthcare_requests, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :user_id, null: false
      t.text :patient_name, null: false
      t.text :reason, null: false
      t.text :prescription_url
      t.string :status, default: "pending"
      t.boolean :approved, default: false
      
      t.timestamps
      
      t.index :user_id
      t.index :status
      t.index :approved
    end
    
    add_foreign_key :healthcare_requests, :users
  end
end
