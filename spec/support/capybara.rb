# spec/support/capybara.rb
require "capybara/rspec"

RSpec.configure do |config|
  # まずは rack_test（高速・JSなし）でOK
  config.before(:each, type: :system) do
    driven_by :rack_test
  end
end
