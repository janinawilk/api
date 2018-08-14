FactoryGirl.define do
  factory :token do
    token "MyString"
    expires_at "2018-08-14 09:07:11"
    user
  end

  factory :other_token, class: Token do
    token "MyString1"
    expires_at "2018-08-14 09:07:11"
    user
  end
end
