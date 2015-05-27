# Inspired by
#   https://brandur.org/request-ids
#   https://github.com/rails/rails/blob/4-2-stable/actionpack/lib/action_dispatch/middleware/request_id.rb

require "securerandom"
# Makes a unique request id available to the recorder_app.request_id env variable
# and sends the same id to the client via the X-Request-Id header.
#
# The unique request id is either based on the X-Request-Id header in the
# request, which would typically be generated  by a firewall, load balancer,
# or the web server, or, if this header is not available, a random uuid. If the
# header is accepted from the outside world, we sanitize it to a max of 255
# chars and alphanumeric and dashes only.
#
# The unique request id can be used to trace a request end-to-end and would
# typically end up being part of log files from multiple pieces of the stack.
class Recorder::App::RequestId
  SLUG = "recorder_app.request_id"

  def initialize(app)
    @app = app
  end

  def call(env)
    env[SLUG] = external_request_id(env) || internal_request_id
    @app.call(env).tap { |_status, headers, _body| headers["X_REQUEST_ID"] = env[SLUG] }
  end

  private

  def external_request_id(env)
    if (request_id = env["HTTP_X_REQUEST_ID"]).to_s.size > 0
      request_id.gsub(/[^\w\-]/, "").first(255)
    end
  end

  def internal_request_id
    SecureRandom.uuid
  end
end
