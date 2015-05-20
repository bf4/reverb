require "rack/test"
RSpec.describe Recorder::API, type: :web do
   include Rack::Test::Methods

   def app
     Recorder::API
   end

   describe "POST /records" do
     let(:delimited_record) do
       "lastname,firstname,gender,favoritecolor,dateofbirth\n"\
       "Last,Woman,Female,Venetian,2000-09-30".freeze
     end

     specify "a single line of data" do
       create_params = {delimited_record: delimited_record}
       post "/api/records", create_params
       expect(status_code).to eq(201)
       expect(response_body).to eq(
         {
           "data" => delimited_record,
         }
       )
     end

     it "returns a 422 error when the table is not parseable" do
       create_params = {delimited_record: "foo;bar"}
       post "/api/records", create_params
       expect(status_code).to eq(422)
       expect(response_body).to eq(
         {
           "errors" => {
             "status" => 422,
             "title" => "Could not parse record",
             "messages" => [
               "No delimiter found for foo;bar"
             ]
           }
         }
       )
     end
   end
   describe "GET /records/gender" # Output 1
   describe "GET /records/birthdate" # Output 2
   describe "GET /records/name" # Output 3

   def response
     last_response
   end

   def status_code
     response.status
   end

   def response_body
     JSON.load(response.body)
   end

end
