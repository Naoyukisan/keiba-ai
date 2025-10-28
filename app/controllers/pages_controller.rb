class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :home  # ← これを追加
  def home; end
end