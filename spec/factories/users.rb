FactoryGirl.define do
  factory :user do
    sequence(:uid) { |n| n }
    sequence(:login) { |n| "jsmith#{n}" }
    sequence(:name) { |n| "John Smith #{n}" }
    url "http://johnsmith.com"
    avatar_url "http://github.com/avatars/jsmith.jpg"
    provider "github"
  end
end
