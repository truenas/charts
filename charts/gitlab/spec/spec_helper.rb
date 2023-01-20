require 'aws-sdk-s3'
require 'open-uri'
require 'open3'
require 'capybara/rspec'
require 'capybara-screenshot/rspec'
require 'selenium-webdriver'
require 'rspec/retry'
require 'gitlab_test_helper'
require 'rspec-parameterized'
require 'pry'

include Gitlab::TestHelper

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome()
  options = Selenium::WebDriver::Chrome::Options.new

  # Chrome won't work properly in a Docker container in sandbox mode
  options.add_argument("no-sandbox")

  # Run headless by default unless CHROME_HEADLESS specified
  options.add_argument("headless") unless ENV['CHROME_HEADLESS'] =~ /^(false|no|0)$/i

  # Disable /dev/shm use in CI. See https://gitlab.com/gitlab-org/gitlab/issues/4252
  options.add_argument("disable-dev-shm-usage") if ENV['CI'] || ENV['CI_SERVER']

  # Explicitly set user-data-dir to prevent crashes. See https://gitlab.com/gitlab-org/gitlab-foss/issues/58882#note_179811508
  options.add_argument("user-data-dir=/tmp/chrome") if ENV['CI'] || ENV['CI_SERVER']

  Capybara::Selenium::Driver.new app,
    browser: :chrome,
    desired_capabilities: capabilities,
    options: options
end

# Keep only the screenshots generated from the last failing test suite
Capybara::Screenshot.prune_strategy = :keep_last_run

# From https://github.com/mattheworiordan/capybara-screenshot/issues/84#issuecomment-41219326
Capybara::Screenshot.register_driver(:headless_chrome) do |driver, path|
  driver.browser.save_screenshot(path)
end

Capybara.configure do |config|
  config.run_server = false
  config.default_driver = :headless_chrome
  config.app_host = gitlab_url
  config.save_path = ::File.expand_path('../tmp/capybara', __dir__)
end

RSpec.configure do |config|
  config.include Capybara::DSL
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.example_status_persistence_file_path = './spec/examples.txt' unless ENV['CI']

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.define_derived_metadata(file_path: %r{/spec/features/}) do |metadata|
    metadata[:type] = :feature
  end

  # show retry status in spec process
  config.verbose_retry = true

  config.around :each, :feature do |example|
    example.run_with_retry retry: 2
  end

  # enable the use of :focus to run a subset of specs
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

  # disable spec test requiring access to k8s cluster
  k8s_access = system('kubectl --request-timeout 1s get nodes >/dev/null 2>&1')
  unless k8s_access
    puts 'Excluding specs that require access to k8s cluster'
    config.filter_run_excluding :type => 'feature'
  end
end
