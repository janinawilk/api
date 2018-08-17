class User < ApplicationRecord
  validates :uid, :login, :provider, presence: true
  validates :uid, uniqueness: { scope: :provider }

  has_one :token
  has_many :articles, dependent: :destroy
  has_many :comments, dependent: :destroy

end
