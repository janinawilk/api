class Article < ApplicationRecord
  scope :recent, -> { order(created_at: :desc) }

  validates :title, :content, presence: true
  validates :slug, uniqueness: true

  belongs_to :user
  has_many :comments, dependent: :destroy

  after_create :generate_slug

  private

  def generate_slug
    update_attribute :slug, "#{title} #{id}".parameterize
  end
end
