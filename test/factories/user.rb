FactoryBot.define do
  factory :user do
    after(:build) do |user|
      user.inbox ||= FactoryBot.build(:inbox, user: user)
      user.outbox ||= FactoryBot.build(:outbox, user: user)
    end

    trait :patient do
      is_patient { true }
      first_name { Faker::Name.first_name }
      last_name { Faker::Name.last_name }
    end

    trait :doctor do
      is_patient { false }
      is_doctor { true }
      first_name { Faker::Name.first_name }
      last_name { Faker::Name.last_name }
    end

    trait :admin do
      is_patient { false }
      is_admin { true }
      first_name { Faker::Name.first_name }
      last_name { Faker::Name.last_name }
    end
  end
end