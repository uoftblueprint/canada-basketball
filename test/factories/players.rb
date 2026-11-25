FactoryBot.define do
  factory :player do
    sequence(:name) { |n| "Player #{n}" }
    birth_year { 2008 }
    height_cm { 185 }
    province { "ON" }
    hometown { "Toronto" }
  end
end
