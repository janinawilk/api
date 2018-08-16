class TokenSerializer < ActiveModel::Serializer
  attributes :id
  has_one :user

  def id
    object.token
  end
end
