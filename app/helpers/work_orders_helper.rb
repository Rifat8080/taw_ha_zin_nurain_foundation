module WorkOrdersHelper
  def work_order_status_badge(work_order)
    case work_order.status
    when "Upcoming"
      content_tag :span, work_order.status, class: "badge bg-primary"
    when "Today"
      content_tag :span, work_order.status, class: "badge bg-warning"
    when "Completed"
      content_tag :span, work_order.status, class: "badge bg-success"
    end
  end

  def days_until_badge(work_order)
    days = work_order.days_until_assignment
    if days > 0
      content_tag :span, "#{days} days", class: "badge bg-info"
    elsif days == 0
      content_tag :span, "Today", class: "badge bg-warning"
    else
      content_tag :span, "#{days.abs} days ago", class: "badge bg-secondary"
    end
  end

  def format_checklist(checklist)
    checklist.split("\n").map(&:strip).reject(&:blank?)
  end
end
