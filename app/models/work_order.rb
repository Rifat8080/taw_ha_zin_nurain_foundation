class WorkOrder < ApplicationRecord
  belongs_to :volunteers_team, foreign_key: :team_id
  belongs_to :assigned_by_user, class_name: "User", foreign_key: :assigned_by

  validates :title, presence: true
  validates :description, presence: true
  validates :checklist, presence: true
  validates :assigned_date, presence: true

  scope :upcoming, -> { where("assigned_date >= ?", Date.current) }
  scope :past, -> { where("assigned_date < ?", Date.current) }
  scope :by_team, ->(team_id) { where(team_id: team_id) }
  scope :assigned_by, ->(user_id) { where(assigned_by: user_id) }

  def team_name
    volunteers_team.name
  end

  def team_district
    volunteers_team.district
  end

  def assigned_by_name
    "#{assigned_by_user.first_name} #{assigned_by_user.last_name}"
  end

  def status
    if assigned_date > Date.current
      "Upcoming"
    elsif assigned_date == Date.current
      "Today"
    else
      "Completed"
    end
  end

  def checklist_items
    checklist.split("\n").reject(&:blank?)
  end

  def days_until_assignment
    (assigned_date - Date.current).to_i
  end
end
