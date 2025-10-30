# spec/requests/prediction_methods_crud_spec.rb
require "rails_helper"

RSpec.describe "PredictionMethods CRUD", type: :request do
  let(:admin) { create(:user, :admin) }

  before { sign_in admin }

  describe "POST /prediction_methods" do
    it "作成成功" do
      params = { prediction_method: { name: "新メソッド", enabled: true } } # ← 必須項目に合わせる
      post "/prediction_methods", params: params
      expect(response).to have_http_status(:found)
      expect(PredictionMethod.last&.name).to eq("新メソッド")
    end

    it "作成失敗（必須欠落）" do
      params = { prediction_method: { name: "" } }
      post "/prediction_methods", params: params
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /prediction_methods/:id" do
    it "更新成功" do
      pm = create(:prediction_method, name: "旧")
      patch "/prediction_methods/#{pm.id}", params: { prediction_method: { name: "新" } }
      expect(response).to have_http_status(:found)
      expect(pm.reload.name).to eq("新")
    end
  end

  describe "DELETE /prediction_methods/:id" do
    it "削除成功" do
      pm = create(:prediction_method)
      delete "/prediction_methods/#{pm.id}"
      expect(response).to have_http_status(:found)
      expect(PredictionMethod.exists?(pm.id)).to be_falsey
    end
  end
end
