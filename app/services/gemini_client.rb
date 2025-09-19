# frozen_string_literal: true
require "net/http"
require "uri"
require "json"

class GeminiClient
  ENDPOINT = "https://generativelanguage.googleapis.com/v1beta/models"
  MODEL    = ENV.fetch("GEMINI_MODEL", "gemini-2.0-flash")  # 必要なら環境変数で差し替え可

  def initialize(api_key: ENV["GEMINI_API_KEY"])
    @api_key = api_key or raise "GEMINI_API_KEY is missing"
  end

  def generate_text(prompt)
    uri = URI("#{ENDPOINT}/#{MODEL}:generateContent?key=#{@api_key}")
    req = Net::HTTP::Post.new(uri, { "Content-Type" => "application/json" })
    req.body = {
      contents: [
        { role: "user", parts: [ { text: prompt.to_s } ] }
      ]
    }.to_json

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, read_timeout: 30) do |http|
      http.request(req)
    end

    raise "Gemini Error: #{res.code} #{res.message} #{res.body}" unless res.is_a?(Net::HTTPSuccess)

    json  = JSON.parse(res.body)
    text  = json.dig("candidates", 0, "content", "parts", 0, "text")
    text.to_s
  end
end
