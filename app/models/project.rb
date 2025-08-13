class Project < ApplicationRecord
    has_one_attached :image
    has_many :donations, dependent: :destroy
    has_many :expenses, dependent: :destroy

    validates :name, presence: true
    validates :description, presence: true

    # Scopes
    scope :active, -> { where(project_status_active: true) }
    scope :inactive, -> { where(project_status_active: false) }
    scope :by_category, ->(category) { where("categories ILIKE ?", "%#{category}%") }

    # Category methods
    def category_list
      categories.to_s.split(',').map(&:strip).reject(&:blank?)
    end

    def has_category?(category)
      categories.to_s.downcase.include?(category.downcase)
    end

    def primary_category
      category_list.first || "General"
    end

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

    # Calculate project metrics
    def total_donations
      donations.sum(:amount)
    end

    def total_expenses
      expenses.sum(:amount)
    end

    def remaining_funds
      total_donations - total_expenses
    end

    def donors_count
      donations.joins(:user).count('DISTINCT users.id')
    end
end
