FactoryBot.define do
  factory :admin do
    sequence(:email) { |n| "admin#{n}@test.com" }
    sequence(:name) { |n| "Admin #{n}" }
    password { "password" }
    role { :manager }

    trait :manager do
      role { :manager }
    end

    trait :analyst do
      role { :analyst }
    end
  end
end
