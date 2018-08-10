FactoryGirl.define do
  factory :article do
    sequence(:title) { |n| "My awesome article #{n}" }
    sequence(:content) { |n| "Even better article #{n}" }
    sequence(:slug) { |n| "my-awesome-article-#{n}" }
  end
end
