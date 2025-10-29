class ErrorsController < ActionController::Base
  layout "error"  # 最低限のレイアウト（アプリ依存を避ける）

  def not_found
    render status: :not_found
  end

  def internal_server_error
    render status: :internal_server_error
  end
end
