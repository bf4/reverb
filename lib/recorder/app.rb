# Inspired by
#  http://code.dblock.org/2012/02/22/grape-api-mounted-on-rack-w-static-pages-tests-jquery-ui-backbonejs-and-even-mongo.html
#  http://stackoverflow.com/a/11202299/879854
#  https://github.com/rails/rails/blob/4-2-stable/actionpack/lib/action_dispatch/middleware/static.rb
#  https://github.com/rails/rails/blob/4-2-stable/railties/lib/rails/application/default_middleware_stack.rb
#  Partly because Rack::Static doesn't play nice with dynamic content
#  and Rack::Cascade was about as much work as the below.
require "logger"
module Recorder
  class App
    autoload :Static, File.expand_path("../middlewares/static", __FILE__)
    autoload :RequestId, File.expand_path("../middlewares/request_id", __FILE__)

    def initialize
      cache_classes = ENV["RACK_ENV"] != "production"
      @app = Rack::Builder.new do
        use Static, Recorder.root.join("public").to_path
        use ::Rack::Runtime
        # use ::Rack::MethodOverride
        # use RequestStore::Middleware
        use RequestId

        # Must come after Rack::MethodOverride to properly log overridden methods
        use Rack::CommonLogger, Logger.new(STDOUT)
        use Rack::ShowExceptions

        unless cache_classes
          use ::Rack::Reloader
        end
        use ::Rack::Head
        use ::Rack::ConditionalGet
        use ::Rack::ETag, "no-cache"
        # use Rack::Cors do
        #   allow do
        #     origins "*"
        #     resource "*", headers: :any, methods: :get
        #   end
        run Recorder::API
      end
    end

    def call(env)
      @app.call(env)
    end

    def self.instance
      @instance ||= new
    end
  end
end
