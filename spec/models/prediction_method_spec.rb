# spec/models/prediction_method_spec.rb
require "rails_helper"

RSpec.describe PredictionMethod, type: :model do
  it "有効なファクトリを持つ" do
    expect(build(:prediction_method)).to be_valid
  end

  describe "バリデーション" do
    it "name は必須" do   # ← カラムに合わせて変更
      pm = build(:prediction_method, name: nil)
      expect(pm).to be_invalid
      expect(pm.errors[:name]).to be_present
    end
  end

  describe "scope" do
    it ".enabled で有効のみ返す" do   # ← 実装の scope 名に合わせて
      enabled = create(:prediction_method, enabled: true)
      _disabled = create(:prediction_method, enabled: false)
      expect(PredictionMethod.where(enabled: true)).to include(enabled)
    end
  end
end
