class VolunteersTeam < ApplicationRecord
  has_many :team_assignments, foreign_key: :team_id, dependent: :destroy
  has_many :volunteers, through: :team_assignments
  has_many :work_orders, foreign_key: :team_id, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :district, presence: true

  scope :by_district, ->(district) { where(district: district) }
  scope :with_volunteers, -> { joins(:volunteers).distinct }

  def volunteers_count
    volunteers.count
  end

  def active_work_orders_count
    work_orders.where("assigned_date >= ?", Date.current).count
  end

  def completed_work_orders_count
    work_orders.where("assigned_date < ?", Date.current).count
  end
end
