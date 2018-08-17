class CommentsController < ApplicationController
  skip_before_action :restrict_access, only: :index
  before_action :set_article

  def index
    @comments = @article.comments.preload(:user)
      .page(params[:page]).per(params[:per_page])

    render json: @comments, include: CommentSerializer::INCLUDED
  end

  def show
    render json: @comment
  end

  def create
    raise AccessDeniedError if @article.user != current_user
    @comment = @article.comments.build(comment_params)

    if @comment.save
      render json: @comment, status: :created, location: @article
    else
      render json: @comment, adapter: :json__api,
        serializer: ActiveModel::Serializer::ErrorSerializer,
        status: :unprocessable_entity
    end
  end

  def update
    if @comment.update(comment_params)
      render json: @comment
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @comment.destroy
  end

  private
    def set_article
      @article = Article.find(params[:article_id])
    end

    def comment_params
      h = params[:data]&.[](:attributes)&.permit(:content) || ActionController::Parameters.new
      h.merge(user_id: current_user.id).permit(:content, :user_id)
    end
end
