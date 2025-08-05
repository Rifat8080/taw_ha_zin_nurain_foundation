class CreateVolunteersTeams < ActiveRecord::Migration[8.0]
  def change
    create_table :volunteers_teams, id: :uuid do |t|
      t.text :name, null: false
      t.text :district, null: false

      t.timestamps
    end
  end
end
