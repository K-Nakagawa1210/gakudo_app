FactoryBot.define do
  factory :user do
    club_name { "テスト用クラブ" }
    email { Faker::Internet.free_email }
    password { "password123" }
    password_confirmation { "password123" }
    address { "東京都千代田区1-1" }
    phone_number { "09012345678" }
  end
end