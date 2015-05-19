RSpec.describe Recorder::Cli do
  it "outputs help text when invalid options given" do
    argv = ["--record", "record.csv"]
    run_with_stubbed_loggers(argv) do |stdout, stderr|
      expect(stdout.readlines).to match_array [
        /Usage/,
        /--file FILE/,
        /--output OUTPUT/,
      ]
      expect(stderr.read).to match /invalid option/
    end
  end

  it "passes --file FILE to be parsed" do
    csv = <<-CSV
lastname,firstname,gender,favoritecolor,dateofbirth
Last,Woman,Female,Venetian,2000-09-30
    CSV
    begin
      file = Tempfile.new("record.csv")
      file.write csv
      file.close
      argv = ["--file", file.path, "--output", "1"]
      expect(Recorder).to receive(:parse).with(csv)
      table = double(to_csv: "")
      allow(Recorder::Views).to receive(:format).and_return(table)
      run_with_stubbed_loggers(argv) do |stdout, stderr|
        expect(stderr.read).to eq("")
        expect(stdout.read).to eq("\n")
      end
    rescue SystemExit
    ensure
      file.close unless file.closed?
      file.unlink
    end
  end

  it "formats the parsed record per --output OUTPUT_NUMBER" do
    csv = <<-CSV
LastName,FirstName,Gender,FavoriteColor,DateOfBirth
Last,Woman,Female,Venetian,2000-09-30
Ultimate,Man,Male,Martian,2000-10-31
Grammer,Bro,Male,Green,2000-11-30
Coder,Rails,Female,Red,2000-12-31
    CSV
    begin
      file = Tempfile.new("record.csv")
      file.write csv
      file.close
      argv = ["--file", file.path, "--output", "3"]
      expected_csv = <<-CSV
lastname,firstname,gender,favoritecolor,dateofbirth
Ultimate,Man,Male,Martian,10/31/2000
Last,Woman,Female,Venetian,09/30/2000
Grammer,Bro,Male,Green,11/30/2000
Coder,Rails,Female,Red,12/31/2000
      CSV
      run_with_stubbed_loggers(argv) do |stdout, stderr|
        expect(stderr.read).to eq("")
        expect(stdout.read).to eq(expected_csv)
      end
    ensure
      file.close unless file.closed?
      file.unlink
    end
  end

  context "validations" do
    it "fails when the the record is not readable" do
      argv = ["--file", "idonotexist.csv", "--output", "3"]
      run_with_stubbed_loggers(argv) do |stdout, stderr|
        expect(stderr.read).to match /not readable/
        expect(stdout.read).to match /Usage/
      end
    end

    it "fails when the the output number is not an available output" do
      argv = ["--file", "record.csv", "--output", "4"]
      run_with_stubbed_loggers(argv) do |stdout, stderr|
        expect(stderr.read).to match /invalid argument: --output 4/
        expect(stdout.read).to match /Usage/
      end
    end
  end
  # Create a command line app that
  #   - takes as input
  #     - a file with a set of records in one of three formats described below,
  #   - and outputs (to the screen)
  #     - the set of records sorted in one of three ways.

  def run_with_stubbed_loggers(argv)
    stdout = StringIO.new
    stderr  = StringIO.new
    cli = Recorder::Cli.new(argv)
    allow(Recorder::Cli).to receive(:new).and_return(cli)
    allow(cli).to receive(:stdout_logger).and_return(stdout)
    allow(cli).to receive(:stderr_logger).and_return(stderr)
    begin
      Recorder::Cli.run(argv)
    rescue SystemExit
    ensure
      stdout.rewind
      stderr.rewind
      yield stdout, stderr
    end
  end
end
