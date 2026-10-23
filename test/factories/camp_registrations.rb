FactoryBot.define do
  factory :camp_registration do
    camp
    player
    team { nil }
  end
end
