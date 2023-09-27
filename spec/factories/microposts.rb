date = [ 42.days.ago, 2.years.ago, 3.days.ago, 10.minutes.ago, 20.days.ago, 5.minutes.ago ]

FactoryBot.define do
  factory :micropost do
    content { Faker::Lorem.sentence(word_count: 5) }
    created_at { date.sample }
    association :user

    trait :most_recent do 
      created_at { Time.zone.now }
    end
  end
end
