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

  def update
    begin
      @article = current_user.articles.find(params[:id])
    if @article.update_attributes(article_params)
      head :no_content
    else
      render json: @article, adapter: :json_api,
        serializer: ActiveModel::Serializer::ErrorSerializer,
        status: :unprocessable_entity
    end
    rescue ActiveRecord::RecordNotFound
      raise AccessDeniedError
    end
  end

  def destroy
    begin
      @article = current_user.articles.find(params[:id])
      @article.destroy
      head :no_content
    rescue ActiveRecord::RecordNotFound
      raise AccessDeniedError
    end
  end

  private

  def article_params
    params[:data]&.[](:attributes)&.permit(:title, :content) || ActionController::Parameters.new
  end
end
