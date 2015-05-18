require "simplecov" # see .simplecov at bottom for run options

require "pathname"
app_root = Pathname File.expand_path("../..", __FILE__)
spec_root = app_root.join("spec")

require spec_root.join("quality_spec")
# in spec/support/ and its subdirectories.
Dir[app_root.join("support/**/*.rb")].each do |f| require f end

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  # Skip specs tagged `:slow` unless SLOW_SPECS is set
  config.filter_run_excluding :slow unless ENV["SLOW_SPECS"]
  # End specs on first failure if FAIL_FAST is set
  config.fail_fast = ENV.include?("FAIL_FAST")
  config.order = :rand
  config.color = true
  config.disable_monkey_patching!
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end

  # :suite after/before all specs
  # :each every describe block
  # :all every it block
end

lib_dir = app_root.join("lib").to_s
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)
require "recorder"
