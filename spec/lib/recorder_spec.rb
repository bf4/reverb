RSpec.describe Recorder, type: :model do
  DELIMITERS =
    { pipes: "|", commas: ",", spaces: " " }
  let(:header_row) {
    %w[LastName FirstName Gender FavoriteColor DateOfBirth]
  }
  let(:data_row) {
    %w[Clinton Bill Male Blue 2015-05-18]
  }
  let(:headers) {
    %i[lastname firstname gender favoritecolor dateofbirth]
  }
  describe "parses a record delimited by" do
    DELIMITERS.each do |name, delimiter|
      # TODO: extract into shared example
      specify "#{name}: '#{delimiter}' delimited" do
        record = build_rows([header_row, data_row], delimiter: delimiter)

        actual = Recorder.parse(record)
        # sanity check
        expect(actual.size).to eq(1)

        expected = data_row[0..-2] << Date.new(2015, 5, 18)
        first_row = actual.first

        # confirm rows parsed by header
        expect(first_row.values_at(*headers)).to eq(expected)
        # confirm date field parsed
        expect(first_row[:dateofbirth]).to be_a(Date)
      end
    end
  end

  def build_rows(rows, delimiter:)
    rows.map { |fields|
      build_row(fields, delimiter: delimiter)
    }.join("\n")
  end

  def build_row(fields, delimiter:)
    fields.join(" #{delimiter} ")
  end
end
