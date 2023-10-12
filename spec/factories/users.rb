FactoryBot.define do
  factory :user, aliases: [:follower, :followed] do
    sequence(:name) { |n| "Example User#{n}"} 
    sequence(:email) { |n| "user#{n}@example.com"}
    password {"foobar"}
    password_confirmation {"foobar"}
    admin { false }
    activated { false }


    trait :with_microposts do 
      after(:create) { |user| create_list(:micropost, 50, user: user) }
      activated { true }
    end

    trait :with_single_micropost do 
      after(:create) { |user| create_list(:micropost, 1, user: user) }
      activated { true }
    end

    trait :activated do 
      activated { true }
    end

    trait :admin do 
      admin { true }
    end
  end
end
 




