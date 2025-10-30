class HistoriesController < ApplicationController
  before_action :authenticate_user!

  def index
    @histories = current_user
      .prediction_histories
      .order(created_at: :desc)
  end

  def show
    @history = current_user.prediction_histories.find(params[:id])
  end
end
