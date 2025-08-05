class User < ApplicationRecord
  has_secure_password
  has_many :donations, dependent: :destroy
  has_one :volunteer, dependent: :destroy
  has_many :assigned_work_orders, class_name: "WorkOrder", foreign_key: :assigned_by, dependent: :nullify

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone_number, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: %w[admin member] }
  validates :address, presence: true

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
end
