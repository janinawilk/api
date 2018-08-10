class UserSerializer < ActiveModel::Serializer
  attributes :id, :uid, :login, :name, :url, :avatar_url, :provider
end
