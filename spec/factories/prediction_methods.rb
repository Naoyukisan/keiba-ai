# spec/factories/prediction_methods.rb
FactoryBot.define do
  factory :prediction_method do
    sequence(:name) { |n| "メソッド#{n}" }
    body   { "これはプロンプト本文のダミーです。" }
    enabled { true }  # モデル側で alias_attribute :enabled, :active 済み

    trait :disabled do
      enabled { false }
    end
  end
end
