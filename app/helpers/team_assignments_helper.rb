module TeamAssignmentsHelper
  def assignment_date_badge(assignment)
    content_tag :span, assignment.created_at.strftime("%b %d, %Y"), class: "badge bg-info"
  end
end
