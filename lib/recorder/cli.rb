require "optparse"
module Recorder
  class Cli
    def self.run(argv = ARGV)
      new(argv.dup).run
    end

    def initialize(argv)
      @options = {}
      @argv = argv
    end

    def run
      parse_options(@argv)
      delimited_record = File.read(options[:file])
      table = Recorder.parse(delimited_record)
      formatted_table = Recorder::Views.format(table, options[:output])
      log formatted_table.to_csv
    end

    private

    attr_reader :options

    def parse_options(args)
      options_parser = OptionParser.new do |parser|
        executable_name = File.basename($PROGRAM_NAME)
        parser.banner = "Usage: #{executable_name} [options]"

        parser.on("-f", "--file FILE", "file to read and process") do |file|
          options[:file] = file
        end
        parser.on("-o", "--output OUTPUT", "specify output format",
                  /\A(#{Recorder::Views.formats.join("|")})\z/, Integer) do |output|
          options[:output] = output
        end
      end
      begin
        options_parser.parse!(args)
        file = options[:file]
        fail ArgumentError, "File missing" if file.nil?
        fail ArgumentError, "File not readable #{file.inspect}" unless File.readable?(file)
        fail ArgumentError, "Output format missing"  if options[:output].nil?
      rescue ArgumentError, OptionParser::ParseError => e
        warn e.message
        log options_parser.help
        exit(1)
      end
    end

    def log(msg = "")
      stdout_logger.puts msg
    end

    def warn(msg = "")
      stderr_logger.puts msg
    end

    def stdout_logger
      STDOUT
    end

    def stderr_logger
      STDERR
    end
  end
end
