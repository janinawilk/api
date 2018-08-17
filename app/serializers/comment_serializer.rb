class CommentSerializer < ActiveModel::Serializer
  INCLUDED = %w[user]
  attributes :id, :content
  has_one :article
  has_one :user
end
