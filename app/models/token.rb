class Token < ApplicationRecord
  validates :token, presence: true
  validates :token, uniqueness: true
  belongs_to :user

  after_initialize :set_token

  private

  def set_token
    loop do
      break if token.present? &&
        !self.class.exists?(token: token)
      self.token = SecureRandom.hex
    end
  end
end
