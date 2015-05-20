require "rack/test"
RSpec.describe Recorder::API, type: :web do
   include Rack::Test::Methods

   def app
     Recorder::API
   end

   describe "POST /records"
   # Post a single data line in any of the 3 formats supported by your existing code
   describe "GET /records/gender" # Output 1
   describe "GET /records/birthdate" # Output 2
   describe "GET /records/name" # Output 3

end
