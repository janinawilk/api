require 'rails_helper'

RSpec.describe Article, type: :model do
  describe '.recent' do
    it 'should return articles in proper order' do
      article_1 = create :article
      article_2 = create :article
      expect(described_class.recent).to eq([article_2, article_1])
      article_2.update_column :created_at, article_1.created_at-1.hour
      expect(described_class.recent).to eq([article_1, article_2.reload])
    end
  end
end
