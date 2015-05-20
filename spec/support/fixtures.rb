module Fixtures
  module_function

  # performance: cache reads from Filesystem
  def get_record(name)
    @records ||= {}
    @records.fetch(name) {
      @records[name] = fixture_path.join(name).read
    }
  end

  def fixture_path
    Recorder.root.join("spec/fixtures")
  end
end
