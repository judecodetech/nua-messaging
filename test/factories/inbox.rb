FactoryBot.define do
  factory :inbox do
    user

    unread_messages { 0 }
  end
end