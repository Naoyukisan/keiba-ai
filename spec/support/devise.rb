# spec/support/devise.rb
RSpec.configure do |config|
  # request/system で使うサインインヘルパ（Devise）
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :system
end
