class User < ApplicationRecord
  has_secure_password
  has_many :donations, dependent: :destroy
  has_one :volunteer, dependent: :destroy
  has_many :assigned_work_orders, class_name: "WorkOrder", foreign_key: :assigned_by, dependent: :nullify

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone_number, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: %w[admin member volunteer] }
  validates :address, presence: true

  after_create :create_volunteer_if_needed
  after_update :create_volunteer_if_needed

  def full_name
    "#{first_name} #{last_name}"
  end

  def is_volunteer?
    volunteer.present?
  end

  def volunteer_teams
    return [] unless is_volunteer?
    volunteer.volunteers_teams
  end

  # Class method to retroactively create volunteers for existing users
  def self.create_missing_volunteers
    where(role: "volunteer").includes(:volunteer).where(volunteers: { id: nil }).find_each do |user|
      user.send(:create_volunteer_if_needed)
    end
  end

  private

  def create_volunteer_if_needed
    if role == "volunteer" && volunteer.blank?
      # Create volunteer record with today's date as joining date
      # Use default volunteer role 'member' unless specified otherwise
      create_volunteer!(
        joining_date: Date.current,
        role: "member"
      )
    elsif role != "volunteer" && volunteer.present?
      # Clean up volunteer record if role changes away from volunteer
      # This will also cascade delete any team assignments due to dependent: :destroy
      volunteer.destroy
    end
  rescue ActiveRecord::RecordInvalid => e
    # If volunteer creation fails, re-raise with more context
    errors.add(:role, "Could not create volunteer record: #{e.message}")
    raise e
  end
end
