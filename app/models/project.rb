class Project < ApplicationRecord
    has_one_attached :image
    has_many :donations, dependent: :destroy
    has_many :expenses, dependent: :destroy

  # Allowed categories for projects. Use a frozen constant to ensure the list is immutable.
  CATEGORIES = %w[Palestine Orphans Food&Water Crisis_Relief Sadaqah Healthcare Education Emergency Community].freeze

    validates :name, presence: true
    validates :description, presence: true
    validate :categories_must_be_allowed

    before_validation :normalize_category

    private

    def normalize_category
      # Trim whitespace; keep legacy comma-separated lists intact so we can validate safely.
      self.categories = categories.to_s.strip if categories.present?
    end

    def categories_must_be_allowed
      return if categories.blank?

      # Accept either a single allowed category or a comma-separated list where at least one
      # of the entries matches the allowed list. Comparison is case-insensitive.
      selected = category_list.map(&:downcase)
      allowed = CATEGORIES.map(&:downcase)

      if (selected & allowed).empty?
        errors.add(:categories, "must include at least one valid category: #{CATEGORIES.join(', ')}")
      end
    end

  public

    # Scopes
    scope :active, -> { where(is_active: true) }
    scope :inactive, -> { where(is_active: false) }
    scope :by_category, ->(category) { where("categories ILIKE ?", "%#{category}%") }

    # Category methods
    def category_list
      categories.to_s.split(",").map(&:strip).reject(&:blank?)
    end

    def has_category?(category)
      categories.to_s.downcase.include?(category.downcase)
    end

    def primary_category
      category_list.first || "General"
    end

    # Helper methods
    def active?
      is_active
    end

    def accepting_donations?
      active?
    end

    def status_text
      active? ? "Active" : "Inactive"
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
      donations.joins(:user).count("DISTINCT users.id")
    end
end
