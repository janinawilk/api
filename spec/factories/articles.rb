FactoryGirl.define do
  factory :article do
    sequence(:title) { |n| "My awesome article #{n}" }
    sequence(:content) { |n| "Even better article #{n}" }
    association :user
  end
end
