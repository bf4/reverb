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

    # TODO: make output prettier
    # TODO: confirm if delimiter should be preserved in formatted csv
    def run
      parse_options!
      table = File.open(options[:file], "rb") { |delimited_record|
        Recorder.parse(delimited_record)
      }
      formatted_table = Recorder::Views.format(table, options[:output])
      log formatted_table.to_csv
    end

    # TODO: Include sort_order defined for each view output in the help
    def parse_options!
      return unless options.empty?
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
        options_parser.parse!(argv)
        file = options[:file]
        output = options[:output]
        fail ArgumentError, "File missing" if file.nil?
        fail ArgumentError, "Output format missing"  if output.nil?
        fail ArgumentError, "File not readable #{file.inspect}" unless File.readable?(file)
      rescue ArgumentError, OptionParser::ParseError => e
        warn e.message
        log options_parser.help
        exit(1)
      end
    end

    private

    attr_reader :options, :argv

    def log(msg = "")
      stdout_logger.puts msg
    end

    def warn(msg = "")
      stderr_logger.puts msg
    end

    # :nocov:
    def stdout_logger
      STDOUT
    end

    def stderr_logger
      STDERR
    end
    # :nocov:
  end
end
