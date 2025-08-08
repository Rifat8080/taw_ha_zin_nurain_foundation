class Project < ApplicationRecord
    has_one_attached :image
    has_many :donations, dependent: :destroy
    has_many :expenses, dependent: :destroy

    validates :name, presence: true
    validates :description, presence: true

    # Scopes
    scope :active, -> { where(project_status_active: true) }
    scope :inactive, -> { where(project_status_active: false) }

    # Helper methods
    def active?
      project_status_active
    end

    def accepting_donations?
      active?
    end

    def status_text
      active? ? 'Active' : 'Inactive'
    end
end
