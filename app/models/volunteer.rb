class Volunteer < ApplicationRecord
  belongs_to :user
  has_many :team_assignments, dependent: :destroy
  has_many :volunteers_teams, through: :team_assignments

  validates :joining_date, presence: true
  validates :role, presence: true, inclusion: { in: %w[coordinator member leader supervisor] }
  validates :user_id, uniqueness: true

  scope :active, -> { joins(:user).where(users: { role: %w[admin member] }) }
  scope :by_role, ->(role) { where(role: role) }

  def full_name
    "#{user.first_name} #{user.last_name}"
  end

  def email
    user.email
  end

  def phone_number
    user.phone_number
  end

  def teams_count
    volunteers_teams.count
  end
end
