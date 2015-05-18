RSpec.describe Recorder, type: :model do
  describe "parses a record delimited by" do
    it "pipes: '|'" do
      file = <<-FILE
LastName | FirstName | Gender | FavoriteColor | DateOfBirth
Clinton | Bill | Male | Blue | 2015-05-18
      FILE
      actual = Recorder.parse(file)
      expected = [
        "Clinton",
        "Bill",
        "Male",
        "Blue",
        Date.new(2015,5,18),
      ]
      expect(actual.size).to eq(1)
      headers = [:lastname, :firstname, :gender, :favoritecolor, :dateofbirth]
      first_row = actual.first
      expect(first_row.values_at(*headers)).to eq(expected)
      expect(first_row[:dateofbirth]).to be_a(Date)
    end
  end
end
