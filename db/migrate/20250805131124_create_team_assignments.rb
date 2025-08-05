class CreateTeamAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :team_assignments, id: :uuid do |t|
      t.uuid :volunteer_id, null: false
      t.uuid :team_id, null: false

      t.timestamps
    end

    add_foreign_key :team_assignments, :volunteers
    add_foreign_key :team_assignments, :volunteers_teams, column: :team_id
    add_index :team_assignments, :volunteer_id
    add_index :team_assignments, :team_id
  end
end
