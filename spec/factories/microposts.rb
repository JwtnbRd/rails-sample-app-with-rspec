date = [ Time.zone.now, 42.days.ago, 2.years.ago, 3.days.ago, 10.minutes.ago ]

FactoryBot.define do
  factory :micropost do
    content { Faker::Lorem.sentence(word_count: 5) }
    created_at { date.sample }
    association :user
  end
end
