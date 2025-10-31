# spec/models/prediction_method_spec.rb
require "rails_helper"

RSpec.describe PredictionMethod, type: :model do
  it "有効なファクトリを持つ" do
    expect(build(:prediction_method)).to be_valid
  end

  describe "バリデーション" do
    it "name は必須" do
      pm = build(:prediction_method, name: nil)
      expect(pm).to be_invalid
      expect(pm.errors[:name]).to be_present
    end
  end

  describe "scope" do
    it ".enabled で有効のみ返す" do
      enabled_pm  = create(:prediction_method, enabled: true)
      _disabled   = create(:prediction_method, enabled: false)
      # ← DBに enabled カラムは無いので where(enabled: true) は不可
      #     モデルのスコープ .enabled を使う
      expect(PredictionMethod.enabled).to include(enabled_pm)
      expect(PredictionMethod.enabled).not_to include(_disabled)
    end
  end
end
