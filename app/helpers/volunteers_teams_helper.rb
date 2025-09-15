module VolunteersTeamsHelper
  def team_status_badge(team)
    if team.volunteers_count > 0
      content_tag :span, "#{team.volunteers_count} volunteers", class: "badge bg-success"
    else
      content_tag :span, "No volunteers", class: "badge bg-warning"
    end
  end

  def district_options
    VolunteersTeam.distinct.pluck(:district).compact.sort.map { |d| [ d, d ] }
  end

  def can_manage_team?(user, team)
  return false unless user && team

  # Admin users can always manage teams
  return true if user.role == "admin"

  # Map the current_user to a Volunteer record and check leadership + membership
  volunteer = user.respond_to?(:volunteer) ? user.volunteer : nil
  return false unless volunteer

  volunteer.role == "leader" && team.volunteers.exists?(id: volunteer.id)
  end
end
