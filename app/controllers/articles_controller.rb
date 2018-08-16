class ArticlesController < ApplicationController
  skip_before_action :restrict_access, only: [:index, :show]

  def index
    @articles = Article.recent.
    page(params[:page]).per(params[:per_page])
    render json: @articles
  end
end
