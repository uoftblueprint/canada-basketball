FactoryBot.define do
  factory :admin do
    sequence(:email) { |n| "admin#{n}@test.com" }
    sequence(:name) { |n| "Admin #{n}" }
    password { "password" }
  end
end
