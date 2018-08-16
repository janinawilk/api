class ArticlesController < ApplicationController
  skip_before_action :restrict_access, only: [:index, :show]

  def index
    @articles = Article.recent.
    page(params[:page]).per(params[:per_page])
    render json: @articles
  end

  def show
    @article = Article.find(params[:id])
    render json: @article
  end

  def create
    @article = Article.new(article_params)
    if @article.save
      render json: @article, status: :created
    else
      render json: @article, adapter: :json_api,
        serializer: ActiveModel::Serializer::ErrorSerializer,
        status: :unprocessable_entity
    end
  end

  private

  def article_params
    params[:data]&.[](:attributes)&.permit(:title, :content) || ActionController::Parameters.new
  end
end
