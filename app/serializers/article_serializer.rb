class ArticleSerializer < ActiveModel::Serializer
INCLUDED = %w[user]

  attributes :id, :title, :content, :slug

  belongs_to :user
end
