class User < ApplicationRecord
  validates :uid, :login, :provider, presence: true 
end
