class Donation < ApplicationRecord
  belongs_to :user
  belongs_to :project

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :user_id, presence: true
  validates :project_id, presence: true
  validate :project_must_be_active

  private

  def project_must_be_active
    return unless project_id.present?
    
    project_record = Project.find_by(id: project_id)
    if project_record && !project_record.is_active
      errors.add(:project, 'is not accepting donations at this time (project is inactive)')
    end
  end
end
