class GeminiController < ApplicationController
  def new
  end

  def create
    @prompt = params[:prompt].to_s
    @answer = GeminiClient.new.generate_text(@prompt)
    render :new
  rescue => e
    @prompt = params[:prompt].to_s
    @error  = e.message
    render :new, status: :bad_request
  end
end
