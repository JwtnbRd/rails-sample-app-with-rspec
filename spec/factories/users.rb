FactoryBot.define do
  factory :user, aliases: [:follower, :followed] do
    sequence(:name) { |n| "Example User#{n}"} 
    sequence(:email) { |n| "user#{n}@example.com"}
    password {"foobar"}
    password_confirmation {"foobar"}

    trait :with_microposts do 
      after(:create) { |user| create_list(:micropost, 10, user: user) }
    end
  end
end
 




