# app/controllers/prediction_methods_controller.rb
require "set"

class PredictionMethodsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_prediction_method, only: %i[show edit update destroy activate]
  # ★ new/create と activate 系だけ管理者に制限（編集・削除は一般ユーザーも可）
  before_action :require_admin_for_admin_actions, only: %i[new create activate activate_previous revert]

  # --- Rails 8 対策: action_methods を明示（create が見えなくなる誤検出の回避） ---
  def self.action_methods
    super + Set.new(%w[index show new create edit update destroy activate activate_previous revert])
  end

  # GET /prediction_methods
  def index
    @prediction_methods = PredictionMethod.order(id: :desc)
  end

  # GET /prediction_methods/:id
  def show; end

  # GET /prediction_methods/new
  def new
    @prediction_method = PredictionMethod.new(active: false)
  end

  # POST /prediction_methods
  def create
    @prediction_method = PredictionMethod.new(prediction_method_params)
    if @prediction_method.save
      redirect_to @prediction_method, notice: "予想方法を作成しました。"
    else
      flash.now[:alert] = @prediction_method.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
    end
  end

  # GET /prediction_methods/:id/edit
  # （一般ユーザーも可）
  def edit; end

  # PATCH/PUT /prediction_methods/:id
  # （一般ユーザーも可。ただし active は管理者のみ更新可）
  def update
    if @prediction_method.update(prediction_method_params)
      redirect_to @prediction_method, notice: "予想方法を更新しました。"
    else
      flash.now[:alert] = @prediction_method.errors.full_messages.join(", ")
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /prediction_methods/:id
  # （一般ユーザーも可）
  def destroy
    @prediction_method.destroy
    redirect_to prediction_methods_path, notice: "予想方法を削除しました。"
  end

  # POST /prediction_methods/:id/activate （管理者のみ）
  def activate
    PredictionMethod.activate!(@prediction_method.id)
    redirect_to prediction_methods_path, notice: "予想方法を「#{@prediction_method.name.presence || "ID:#{@prediction_method.id}"}」に切り替えました。"
  rescue => e
    Rails.logger.error(e.full_message)
    redirect_to prediction_methods_path, alert: "切り替えに失敗しました。"
  end

  # POST /prediction_methods/activate_previous （管理者のみ）
  def activate_previous
    prev = PredictionMethod.activate_previous!
    redirect_to prediction_methods_path, notice: "予想方法を「#{prev.name.presence || "ID:#{prev.id}"}」に戻しました。"
  rescue ActiveRecord::RecordNotFound => e
    redirect_to prediction_methods_path, alert: e.message
  rescue => e
    Rails.logger.error(e.full_message)
    redirect_to prediction_methods_path, alert: "切り替えに失敗しました。"
  end

  # POST /prediction_methods/revert （管理者のみ：ダミー）
  def revert
    redirect_to prediction_methods_path, alert: "未実装のため処理しませんでした。"
  end

  private

  def set_prediction_method
    @prediction_method = PredictionMethod.find(params[:id])
  end

  # 一般ユーザーは :active/:enabled を更新できないようにする
  def prediction_method_params
    permitted = [:name, :body]
    if current_user&.admin?
      # フォームは :active、リクエストSpecは :enabled を送るので両方許可
      permitted += [:active, :enabled]
    end
    params.require(:prediction_method).permit(*permitted)
  end

  # 管理者だけに制限するアクション用
  def require_admin_for_admin_actions
    unless current_user&.admin?
      redirect_to prediction_methods_path, alert: "管理者のみ実行できます。"
    end
  end
end
