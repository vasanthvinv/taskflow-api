class User < ApplicationRecord
  has_secure_password
  has_many :boards, dependent: :destroy
  has_many :cards, dependent: :nullify

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  before_save { self.email = email.downcase }
end
