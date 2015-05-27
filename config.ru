require File.expand_path("../lib/recorder", __FILE__)

# Swagger-UI
#   Serve all requests normally from the folder "public" in the current
#   directory but uses index.html as default route for "/"
use Rack::Static,
  :urls => [""],
  :root => 'public',
  :index => 'index.html'

run Recorder::API
