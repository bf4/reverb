require "rack/test"
RSpec.describe Recorder::API, type: :web do
  include Rack::Test::Methods

  def app
    Recorder::API
  end

  describe "POST /records" do
    let(:delimited_record) do
      "lastname,firstname,gender,favoritecolor,dateofbirth\n"\
        "Last,Woman,Female,Venetian,2000-09-30\n".freeze
    end

    specify "as a single line of data" do
      create_params = { delimited_record: delimited_record }
      post "/api/records", create_params
      expect(status_code).to eq(201)
      expect(response_body).to eq(
        "data" => delimited_record,
      )
    end

    specify "as a file" do
      file = Fixtures.fixture_path.join("output1.csv")
      rack_file = Rack::Test::UploadedFile.new(file)
      create_params = { delimited_record: rack_file }
      post "/api/records", create_params

      expect(status_code).to eq(201)
      expect(response_body).to eq(
        "data" => Fixtures.get_record("output1.csv"),
      )
    end

    it "returns a 422 error when the table is not parseable" do
      create_params = { delimited_record: "foo;bar" }
      post "/api/records", create_params
      expect(status_code).to eq(422)
      expect(response_body).to eq(
        "errors" => {
          "status" => 422,
          "title" => "Could not parse record",
          "messages" => [
            "No delimiter found for foo;bar"
          ]
        }
      )
    end
  end

  ## Output 1
  it "GET /records/gender" do
    create_params = { delimited_record: Fixtures.get_record("record.csv") }
    post "/api/records", create_params

    get "/api/records/gender"

    expect(status_code).to eq(200)
    expect(response_body).to eq(
      "data" => Fixtures.get_record("output1.csv"),
    )
  end

  ## Output 2
  it "GET /records/birthdate" do
    create_params = { delimited_record: Fixtures.get_record("record.csv") }
    post "/api/records", create_params

    get "/api/records/birthdate"

    expect(status_code).to eq(200)
    expect(response_body).to eq(
      "data" => Fixtures.get_record("output2.csv"),
    )
  end

  ## Output 3
  it "GET /records/name" do
    create_params = { delimited_record: Fixtures.get_record("record.csv") }
    post "/api/records", create_params

    get "/api/records/name"

    expect(status_code).to eq(200)
    expect(response_body).to eq(
      "data" => Fixtures.get_record("output3.csv"),
    )
  end

  private

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
