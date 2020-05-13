FactoryBot.define do
  factory :message do
    body { Faker::Quotes::Shakespeare.as_you_like_it_quote }

    outbox
    inbox

    read { false }
    created_at { Date.current.in_time_zone }

    trait :sent_1_week_ago do
      created_at { DateTimeHelper.one_week_ago }
    end
  end
end