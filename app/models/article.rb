class Article < ApplicationRecord
  scope :recent, -> { order(created_at: :desc) }
  validates :title, :content, presence: true
end
