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

  describe "identifies a record's column delimiter" do
    DELIMITERS.each do |name, delimiter|
      specify "as #{name}: '#{delimiter}' delimited" do
        row = build_row(data_row, delimiter: delimiter)
        expect(Recorder.delimiter_for(row)).to eq(delimiter)
      end
    end
  end

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

  it "builds up and combines parsed records" do
    builder = Recorder::Builder.new

    data_row1 = %w[Fleischer Benjamin Male Blue] << Date.new(2015, 10, 5)
    record1 = build_rows([header_row, data_row1], delimiter: "|")
    builder.parse(record1)

    data_row2 = %w[Zold Henrietta Female Plaid] << Date.new(2045, 5, 2)
    record2 = build_rows([header_row, data_row2], delimiter: "|")
    builder.parse(record2)

    actual = builder.records
    expect(actual.size).to eq(2)
    expect(actual.flat_map { |table| table.map(&:fields) }).to match_array [
      data_row1,
      data_row2
    ]

    combined_records = builder.combine_records!
    expect(builder.records.size).to eq(1)
    expect(combined_records.first.map(&:fields)).to match_array [
      data_row1,
      data_row2
    ]
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
