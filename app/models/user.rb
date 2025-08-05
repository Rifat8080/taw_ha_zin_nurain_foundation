class User < ApplicationRecord
  has_secure_password
  has_many :donations, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone_number, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: %w[admin member] }
  validates :address, presence: true
end
