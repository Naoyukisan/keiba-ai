# spec/requests/prediction_methods_crud_spec.rb
require "rails_helper"

RSpec.describe "PredictionMethods CRUD", type: :request do
  let(:admin) { create(:user, :admin) }

  before { sign_in admin }

  describe "POST /prediction_methods" do
    it "作成成功" do
      params = {
        prediction_method: {
          name: "新メソッド",
          body: "これは本文です。",
          enabled: true
        }
      }
      post "/prediction_methods", params: params
      expect(response).to have_http_status(:found)
      expect(PredictionMethod.last&.name).to eq("新メソッド")
      expect(PredictionMethod.last&.active).to eq(true) # alias動作確認
    end

    it "作成失敗（必須欠落）" do
      params = { prediction_method: { name: "", body: "" } }
      post "/prediction_methods", params: params
      # Rackの警告は出るが RSpec では 422 で問題なし
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /prediction_methods/:id" do
    it "更新成功" do
      pm = create(:prediction_method, name: "旧", body: "本文")
      patch "/prediction_methods/#{pm.id}", params: { prediction_method: { name: "新" } }
      expect(response).to have_http_status(:found)
      expect(pm.reload.name).to eq("新")
    end
  end

  describe "DELETE /prediction_methods/:id" do
    it "削除成功" do
      pm = create(:prediction_method, body: "本文")
      delete "/prediction_methods/#{pm.id}"
      expect(response).to have_http_status(:found)
      expect(PredictionMethod.exists?(pm.id)).to be_falsey
    end
  end
end
