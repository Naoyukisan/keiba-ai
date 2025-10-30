# spec/factories/prediction_methods.rb
FactoryBot.define do
  factory :prediction_method do
    sequence(:name) { |n| "メソッド#{n}" }     # ← name:string がある想定。無ければ既存カラム名に変更
    enabled { true }                            # ← boolean があるなら
  end
end
