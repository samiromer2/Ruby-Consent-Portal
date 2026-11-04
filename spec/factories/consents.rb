FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "rspec-user-#{n}@example.com" }
    password { "password" }
    password_confirmation { "password" }
  end

  factory :citizen do
    user
    sequence(:name) { |n| "RSpec Citizen #{n}" }
    email { user.email_address }
  end

  factory :service do
    sequence(:name) { |n| "RSpec Service #{n}" }
  end

  factory :consent do
    citizen
    service
  end
end
