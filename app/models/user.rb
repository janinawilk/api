class User < ApplicationRecord
  validates :uid, :login, :provider, presence: true
  validates :uid, uniqueness: { scope: :provider }

  has_one :token
end
