module VolunteersHelper
  def volunteer_role_options
    [
      [ "Coordinator", "coordinator" ],
      [ "Member", "member" ],
      [ "Leader", "leader" ],
      [ "Supervisor", "supervisor" ]
    ]
  end

  def volunteer_status_badge(volunteer)
    if volunteer.user.role == "admin"
      content_tag :span, "Admin", class: "badge bg-primary"
    else
      content_tag :span, "Member", class: "badge bg-secondary"
    end
  end

  def volunteer_role_badge(role)
    case role
    when "coordinator"
      content_tag :span, role.capitalize, class: "badge bg-warning"
    when "leader"
      content_tag :span, role.capitalize, class: "badge bg-success"
    when "supervisor"
      content_tag :span, role.capitalize, class: "badge bg-info"
    else
      content_tag :span, role.capitalize, class: "badge bg-secondary"
    end
  end
end
