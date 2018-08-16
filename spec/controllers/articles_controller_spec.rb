require 'rails_helper'

describe ArticlesController do
  describe 'GET :index' do
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

  describe 'GET :show' do
    let(:article) { create :article }

    it 'should return success response' do
      get :show, params: { id: article.id }
      expect(response).to have_http_status(:ok)
    end

    it 'should return proper json' do
      get :show, params: { id: article.id }
      expect(json_data['attributes']).to include({
        'title' => article.title,
        'content' => article.content,
        'slug' => article.slug
        })
    end
  end

  describe 'POST :create' do
    context 'when user not authorized' do
      let(:authorization_error) {
        {
          "status" => "401",
          "source" => { "pointer" => "/code" },
          "title" =>  "Authorization failed",
          "detail" => "The code parameter or authorization header is invalid"
        }
      }

      it 'should return 401 http status' do
        post :create
        expect(response).to have_http_status(:unauthorized)
      end

      it 'should return error info in the response body' do
        post :create
        expect(json['errors'].length).to eq(1)
        expect(json['errors'][0]).to eq(authorization_error)
      end

      it 'should create the article' do
        expect{ post :create }.not_to change{ Article.count }
      end
    end

    context 'when user authorized' do
      let(:user) { create :user }
      let(:token) { create :token }

      before { request.headers['authorization'] = "Bearer #{token.token}" }

      context 'when request invalid' do
        it 'should not create article without required parameters' do
          expect{ post :create }.not_to change{ Article.count }
        end

        it 'should return 422 http status if article is invalid' do
          post :create
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should include error information about invalid attributes' do
          post :create
          expect(json['errors'].length).to eq(2)
          expect(json['errors']).to contain_exactly(
            {
              'source' => { 'pointer' => '/data/attributes/title' },
              'detail' => "can't be blank"
            },
            {
              'source' => { 'pointer' => '/data/attributes/content' },
              'detail' => "can't be blank"
            }
          )
        end
      end
      context 'when request valid' do
        let(:valid_article_attributes) do
          { data: { attributes: { title: 'Sample title', content: 'Sample content' } } }
        end

        it 'should return 201 http status' do
          post :create, params: valid_article_attributes
          expect(response).to have_http_status(:created)
        end

        it 'should create an article' do
          expect(Article.exists?(title: 'Sample title')).to be_falsey
          expect{ post :create, params: valid_article_attributes }.to change{ Article.count}.by(1)
          article = Article.find_by(title: 'Sample title')
          expect(article).to be_present
          expect(article.content).to eq('Sample content')
        end

        it 'should include article data in response' do
          post :create, params: valid_article_attributes
          expect(json['data']['attributes']).to include(
            valid_article_attributes[:data][:attributes].stringify_keys
          )
        end
      end
    end
  end
end
