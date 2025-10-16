class HistoriesController < ApplicationController
  def index
    @histories = PredictionHistory.order(created_at: :desc)
  end

  def show
    @history = PredictionHistory.find(params[:id])
  end
end
