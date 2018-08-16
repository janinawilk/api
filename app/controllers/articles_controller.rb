class ArticlesController < ApplicationController
  skip_before_action :restrict_access, only: [:index, :show]

  def index
    @articles = Article.recent.
    page(params[:page]).per(params[:per_page])
    render json: @articles, include: ArticleSerializer::INCLUDED
  end

  def show
    @article = Article.find(params[:id])
    render json: @article, include: ArticleSerializer::INCLUDED
  end

  def create
    @article = current_user.articles.build(article_params)
    if @article.save
      render json: @article, status: :created, include: ArticleSerializer::INCLUDED
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
