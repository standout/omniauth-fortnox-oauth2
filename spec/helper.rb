# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path(__dir__)
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'rspec'
require 'webmock/rspec'
require 'omniauth'
require 'omniauth-fortnox-oauth2'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.extend OmniAuth::Test::StrategyMacros, type: :strategy
  config.include WebMock::API
end
