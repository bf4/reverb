source "https://rubygems.org"
# Normally I'd lock the Ruby version in the Gemfile, but
# skipping that for convenience of anyone running the code challenge.
# ruby "2.2.2"

# app server
gem "thin"
# api DSL
gem "grape", "~> 0.11"

group :development do
  # https://github.com/swagger-rb/swagger-rb
  gem "swagger-core"
  # documentation
  gem "yard"
  # style
  gem "rubocop", "0.30.0"
end

group :test, :development do
  gem "rack-test"

  gem "rspec", "~> 3.2"
  gem "bundler", "~> 1.7"
  gem "rake", "~> 10.0"
  gem "simplecov", "~> 0.9"
  gem "code_notes"

  # continuous testing
  # guard and deps
  gem "guard"
  gem "guard-rspec",          require:  false
  gem "guard-bundler",        require:  false
  # file system change event handling
  gem "listen",     "~> 2.7.3"
  gem "rb-fchange", "~> 0.0.6", require: false
  gem "rb-fsevent", "~> 0.9.4", require: false

  # notification handling
  gem "terminal-notifier-guard", "~> 1.5.3", require: false

  # Debugging
  # Guard includes 'pry', so let's make that explicit
  # https://github.com/guard/guard#interactions
  # Add: edit -c, play -l number, whereami, wtf
  gem "pry",       require:  true
  # see https://github.com/pry/pry/wiki/Editor-integration
  #     https://github.com/pry/pry/wiki/Documentation-browsing
  #     https://github.com/pry/pry/wiki/Exceptions
  #     http://www.confreaks.com/videos/2864-rubyconf2013-repl-driven-development-with-pry
  # On OSX, edit ~/.editrc and add
  # bind "^R" em-inc-search-prev
  # to get 'readline' support
  #
  # Adds: 'step', 'next', 'finish', 'continue', and 'break'  commands to control execution.
  gem "pry-byebug",   require:  false
  # see https://github.com/deivid-rodriguez/pry-byebug#execution-commands
  # command completion
  gem "bond",      require:  false
  # see .pryrc for more configurations
end
