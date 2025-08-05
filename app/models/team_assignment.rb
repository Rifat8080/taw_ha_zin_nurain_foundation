class TeamAssignment < ApplicationRecord
  belongs_to :volunteer
  belongs_to :volunteers_team, foreign_key: :team_id

  validates :volunteer_id, uniqueness: { scope: :team_id, message: "is already assigned to this team" }

  scope :by_volunteer, ->(volunteer_id) { where(volunteer_id: volunteer_id) }
  scope :by_team, ->(team_id) { where(team_id: team_id) }

  def volunteer_name
    volunteer.full_name
  end

  def team_name
    volunteers_team.name
  end

  def team_district
    volunteers_team.district
  end
end
