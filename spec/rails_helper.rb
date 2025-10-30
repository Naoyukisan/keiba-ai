# spec/rails_helper.rb
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"

# support 配下を自動読み込み
Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

# 未実行のマイグレーションがあれば警告
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_paths = [Rails.root.join("spec/fixtures")]

  # transactional_fixtures: Systemテスト以外はトランザクションでOK
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  # FactoryBotの短縮記法（create(:user) など）
  config.include FactoryBot::Syntax::Methods
end
