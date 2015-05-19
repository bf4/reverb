RSpec.describe Recorder, type: :model do
  # TODO: use delimiter definitions from Recorder.delimiters
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
    record2 = build_rows([header_row, data_row2], delimiter: " ")
    builder.parse(record2)

    records = builder.records
    expect(records.size).to eq(2)
    expect(records.flat_map { |table| table.map(&:fields) }).to match_array [
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

  describe "outputing views" do
    it "must specify a sort_order" do
      view = Class.new(Recorder::Views::View)
      record = build_rows([header_row, data_row, data_row], delimiter: ",")
      table = Recorder.parse(record)
      expect {
        view.format(table)
      }.to raise_error(RuntimeError, /sort_order/)
    end

    it "fails when an unhandled sort_order" do
      view = Class.new(Recorder::Views::View) do
        def self.sort_order
          [[:lastname, :famousness]]
        end
      end

      record = build_rows([header_row, data_row, data_row], delimiter: ",")
      table = Recorder.parse(record)
      expect {
        view.format(table)
      }.to raise_error(RuntimeError, /unknown sort direction/i)
    end

    specify "Output1: sorted by gender (females before males) then by last name ascending" do # rubocop:disable Metrics/LineLength
      data_rows = [
        %w[Last Woman Female Venetian 2000-09-30],
        %w[Ultimate Man Male Martian 2000-10-31],
        %w[Grammer Bro Male Green 2000-11-30],
        %w[Coder Rails Female Red 2000-12-31],
      ]
      record = build_rows([header_row] + data_rows, delimiter: ",")
      table = Recorder.parse(record)
      formatted_table = Recorder::Views::Output1.format(table)

      expected = [
        header_row.map(&:downcase).map(&:intern),
        %w[Coder Rails Female Red 12/31/2000],
        %w[Last Woman Female Venetian 09/30/2000],
        %w[Grammer Bro Male Green 11/30/2000],
        %w[Ultimate Man Male Martian 10/31/2000],
      ]
      expect(formatted_table.to_a).to eq(expected)
    end

    specify "Output2: sorted by birth date, ascending." do
      data_rows = [
        %w[Ultimate Man Male Martian 2000-10-31],
        %w[Last Woman Female Venetian 2000-09-30],
        %w[Coder Rails Female Red 2000-12-31],
        %w[Grammer Bro Male Green 2000-11-30],
      ]
      record = build_rows([header_row] + data_rows, delimiter: "|")
      table = Recorder.parse(record)
      formatted_table = Recorder::Views::Output2.format(table)

      expected = [
        header_row.map(&:downcase).map(&:intern),
        %w[Last Woman Female Venetian 09/30/2000],
        %w[Ultimate Man Male Martian 10/31/2000],
        %w[Grammer Bro Male Green 11/30/2000],
        %w[Coder Rails Female Red 12/31/2000],
      ]
      expect(formatted_table.to_a).to eq(expected)
    end

    specify "Output3: sorted by last name, descending." do
      data_rows = [
        %w[Last Woman Female Venetian 2000-09-30],
        %w[Ultimate Man Male Martian 2000-10-31],
        %w[Grammer Bro Male Green 2000-11-30],
        %w[Coder Rails Female Red 2000-12-31],
      ]
      record = build_rows([header_row] + data_rows, delimiter: " ")
      table = Recorder.parse(record)
      formatted_table = Recorder::Views::Output3.format(table)

      expected = [
        header_row.map(&:downcase).map(&:intern),
        %w[Ultimate Man Male Martian 10/31/2000],
        %w[Last Woman Female Venetian 09/30/2000],
        %w[Grammer Bro Male Green 11/30/2000],
        %w[Coder Rails Female Red 12/31/2000],
      ]
      expect(formatted_table.to_a).to eq(expected)
    end

    it "formats the output for the given output integer" do
      data_rows = [
        %w[Last Woman Female Venetian 2000-09-30],
        %w[Ultimate Man Male Martian 2000-10-31],
        %w[Grammer Bro Male Green 2000-11-30],
        %w[Coder Rails Female Red 2000-12-31],
      ]
      record = build_rows([header_row] + data_rows, delimiter: " ")
      table = Recorder.parse(record)
      formatted_table = Recorder::Views.format(table, 3)

      expected = [
        header_row.map(&:downcase).map(&:intern),
        %w[Ultimate Man Male Martian 10/31/2000],
        %w[Last Woman Female Venetian 09/30/2000],
        %w[Grammer Bro Male Green 11/30/2000],
        %w[Coder Rails Female Red 12/31/2000],
      ]
      expect(formatted_table.to_a).to eq(expected)
    end

    it "raises an ArgumentError for an unknown output integer" do
      expect {
        Recorder::Views.format(Class.new, 4)
      }.to raise_error(ArgumentError, /no such/i)
    end

    it "knows the available outputs" do
      expect(Recorder::Views.formats).to match_array [1,2,3]
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
