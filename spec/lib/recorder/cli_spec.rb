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
    it "fails when no file is given" do
      argv = ["--output", "3"]
      parse_options_with_stubbed_loggers(argv) do |stdout, stderr|
        expect(stderr.read).to match /File missing/i
        expect(stdout.read).to match /Usage/
      end
    end

    it "fails when the the record is not readable" do
      argv = ["--file", "idonotexist.csv", "--output", "3"]
      parse_options_with_stubbed_loggers(argv) do |stdout, stderr|
        expect(stderr.read).to match /not readable/
        expect(stdout.read).to match /Usage/
      end
    end

    it "fails when no output is given" do
      argv = ["--file", "idonotexist.csv"]
      parse_options_with_stubbed_loggers(argv) do |stdout, stderr|
        expect(stderr.read).to match /Output format missing/i
        expect(stdout.read).to match /Usage/
      end
    end

    it "fails when the the output number is not an available output" do
      argv = ["--file", "record.csv", "--output", "4"]
      parse_options_with_stubbed_loggers(argv) do |stdout, stderr|
        expect(stderr.read).to match /invalid argument: --output 4/
        expect(stdout.read).to match /Usage/
      end
    end
  end

  def run_with_stubbed_loggers(argv)
    stdout, stderr = stub_loggers(argv) { |_cli|
      Recorder::Cli.run(argv)
    }
    yield stdout, stderr
  end

  def parse_options_with_stubbed_loggers(argv)
    stdout, stderr = stub_loggers(argv) { |cli|
      cli.parse_options!
    }
    yield stdout, stderr
  end

  def stub_loggers(argv)
    stdout = StringIO.new
    stderr  = StringIO.new
    cli = Recorder::Cli.new(argv)
    allow(Recorder::Cli).to receive(:new).and_return(cli)
    allow(cli).to receive(:stdout_logger).and_return(stdout)
    allow(cli).to receive(:stderr_logger).and_return(stderr)
    begin
      yield cli
    rescue SystemExit
    ensure
      stdout.rewind
      stderr.rewind
      return [stdout, stderr]
    end
  end
end
