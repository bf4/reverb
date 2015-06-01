require "recorder/schema"

RSpec.describe Recorder::Schema do
  it "tests" do
    api = Recorder::Schema.build
    schema = Recorder.root.join("public", "api-docs.json").to_path
    json_api = Swagger.load(schema)
    begin
      expect(api.to_json).to eq(json_api.to_json)
    ensure
      Recorder::Schema.write(api)
    end
  end
end
