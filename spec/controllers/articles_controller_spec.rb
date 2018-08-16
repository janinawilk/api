require 'rails_helper'

describe ArticlesController do
  it 'should return success response' do
    get :index
    expect(response).to have_http_status(:ok)
  end

  it 'should return proper json' do
    articles = create_list :article, 2
    get :index
    articles.each_with_index do |article, index|
      expect(json_data[index-1]['attributes']).to include({
      'title' => article.title,
      'content' => article.content,
      'slug' => article.slug })
    end
  end

  it 'should return articles in proper order' do
    old_article = create :article
    recent_article = create :article
    get :index
    expect(json_data[0]['id']).to eq(recent_article.id.to_s)
    expect(json_data[1]['id']).to eq(old_article.id.to_s)
  end

  it 'should test pagination' do
    create_list :article, 3
    get :index, params: { page: 2, per_page: 1 }
    expect(json_data.length).to eq(1)
    expected_id = Article.recent.second.id.to_s
    expect(json_data[0]['id']).to eq(expected_id)
  end
end
