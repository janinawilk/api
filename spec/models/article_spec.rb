require 'rails_helper'

RSpec.describe Article, type: :model do
  describe 'validations' do
    it 'should have valid factory' do
      expect(build :article).to be_valid
    end

    it 'should validate presence of title' do
      article = build :article, title: nil
      expect(article).not_to be_valid
      expect(article.errors.messages[:title])
        .to include("can't be blank")
    end

    it 'should validate presence of content' do
      article = build :article, content: nil
      expect(article).not_to be_valid
      expect(article.errors.messages[:content])
        .to include("can't be blank")
    end
  end

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
