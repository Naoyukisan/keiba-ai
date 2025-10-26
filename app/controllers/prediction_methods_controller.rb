class PredictionMethodsController < ApplicationController
  def activate_previous
    prev = PredictionMethod.activate_previous!
    flash[:notice] = "予想方法を「#{prev.name.presence || "ID:#{prev.id}"}」に戻しました。"
  rescue ActiveRecord::RecordNotFound => e
    flash[:alert] = e.message
  rescue => e
    Rails.logger.error(e.full_message)
    flash[:alert] = "切り替えに失敗しました。"
  ensure
    redirect_to new_improvement_path
  end
end