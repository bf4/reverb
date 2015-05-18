RSpec.describe Recorder, type: :model do
  describe "parses a record delimited by" do
    {pipes: "|", commas: ",", spaces: " "}.each do |name, delimiter|
      it "#{name}: '#{delimiter}' delimited" do
        record = build_rows([
          %w[LastName FirstName Gender FavoriteColor DateOfBirth],
          %w[Clinton Bill Male Blue 2015-05-18],
        ], delimiter: delimiter)

        actual = Recorder.parse(record)
        expect(actual.size).to eq(1)

        expected = [
          "Clinton",
          "Bill",
          "Male",
          "Blue",
          Date.new(2015,5,18),
        ]
        first_row = actual.first
        headers = [:lastname, :firstname, :gender, :favoritecolor, :dateofbirth]

        expect(first_row.values_at(*headers)).to eq(expected)
        expect(first_row[:dateofbirth]).to be_a(Date)
      end
    end
  end

  def build_rows(rows, delimiter:)
    rows.map do |fields|
      build_row(fields, delimiter: delimiter)
    end.join("\n")
  end

  def build_row(fields, delimiter:)
    fields.join(" #{delimiter} ")
  end
end
