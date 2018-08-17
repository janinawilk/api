require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  describe "GET #index" do
    let(:article) { create :article }

    it "returns a success response" do
      get :index, params: { article_id: article.id }
      expect(response).to have_http_status(:ok)
    end

    it 'should return only articles comments in response' do
      article_comment = create :comment, article: article
      create :comment
      get :index, params: { article_id: article.id }
      expect(json['data'].length).to eq(1)
      expect(json['data'][0]['id']).to eq(article_comment.id.to_s)
    end

    it 'should return proper attributes in the response' do
      article_comment = create :comment, article: article
      get :index, params: { article_id: article.id }
      comment_data = json['data'][0]
      expect(comment_data['attributes']).to eq({
        'content' => article_comment.content })
    end

    it 'should have article and user in relationships' do
      article_comment = create :comment, article: article
      create_list :comment, 50, article: article
      get :index, params: { article_id: article.id }
      comment_relationships = json['data'][0]['relationships']
      expect(comment_relationships['article']['data']['id'])
        .to eq(article.id.to_s)
      expect(comment_relationships['user']['data']['id'])
        .to eq(article_comment.user_id.to_s)
    end

    it 'should have user in the included section' do
      article_comment = create :comment, article: article
      get :index, params: { article_id: article.id }
      expect(json['included'].length).to eq(1)
      comment_included = json['included'][0]
      expect(comment_included['type']).to eq('users')
      expect(comment_included['id']).to eq(article_comment.user.id.to_s)
    end
  end

  describe "POST #create" do


    context 'when user is not authorized' do
      let(:authorization_error) {
        {
          "status" => "401",
          "source" => { "pointer" => "/code" },
          "title" =>  "Authorization failed",
          "detail" => "The code parameter or authorization header is invalid"
        }
      }
      let(:article) { create :article }

      it 'should return 401 http status' do
        post :create, params: { article_id: article.id }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'should return error info in the response body' do
        post :create, params: { article_id: article.id }
        expect(json['errors'].length).to eq(1)
        expect(json['errors'][0]).to eq(authorization_error)
      end

      it 'should not create the comment' do
        expect{ post :create, params: { article_id: article.id } }.not_to change{ Comment.count }
      end
    end

    context 'when user is authorized' do
      let(:valid_attributes) {
        { data: { attributes: { content: "Sample comment" } } }
      }
      let(:user) { create :user }
      let(:token) { create :token, user: user }

      before { request.headers['authorization'] = "Bearer #{token.token}" }

      context 'when trying to add comment to owned article' do
        let(:article) { create :article, user: user }

        context "with valid params" do

          it 'should return 201 status code' do
            post :create, params: valid_attributes
              .merge(article_id: article.id)
            expect(response).to have_http_status(:created)
          end

          it "creates a new Comment" do
            expect {
              post :create, params: valid_attributes
                .merge(article_id: article.id)
            }.to change(Comment, :count).by(1)
          end

          it "renders a JSON response with the new comment" do
            post :create, params: valid_attributes
              .merge(article_id: article.id)
            expect(json['data']['attributes']).to eq({
              'content' => 'Sample comment'
              })
            comment = Comment.last
            expect(comment.article).to eq(article)
            expect(comment.user).to eq(user)
            expect(comment.content).to eq('Sample comment')
          end
        end

        context "with invalid params" do
          let(:invalid_attributes) {
            { data: { attributes: { content: "" } } }
          }

          it "renders a JSON response with errors for the new comment" do
            post :create, params: invalid_attributes.merge(article_id: article.id)
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'should not create comment' do
            expect{ post :create, params: invalid_attributes.merge(article_id: article.id) }.not_to change(Comment, :count)
          end

          it 'should have proper message in the body' do
            post :create, params: invalid_attributes.merge(article_id: article.id)
            expect(json['errors'].length).to eq(1)
            expect(json['errors']).to contain_exactly(
              {
                'source' => { 'pointer' => '/data/attributes/content' },
                'detail' => "can't be blank"
              }
            )
          end
        end
      end

      context 'when trying to add comment on other user article' do
        let(:forbidden_error) {
          {
            "status" => "403",
            "source" => { "pointer" => "/code" },
            "title" =>  "Access denied",
            "detail" => "You have no rights to access this resource"
          }
        }

        let (:other_article) { create :article }

        it 'should return 403 http status' do
          post :create, params: valid_attributes
            .merge(article_id: other_article.id)
          expect(response).to have_http_status(:forbidden)
        end

        it 'should return error information in response body' do
          post :create, params: valid_attributes.merge(article_id: other_article.id)
          expect(json['errors'][0]).to eq(forbidden_error)
        end

        it 'should not create comment for not owned artile' do
          expect{
            post :create, params: valid_attributes.merge(article_id: other_article.id)
          }.not_to change{ Comment.count }
        end
      end
    end
  end
end
