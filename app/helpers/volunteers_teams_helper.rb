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
end
