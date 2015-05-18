require "pathname"

module Recorder
  ROOT = Pathname File.expand_path("../..", __FILE__)
  private_constant :ROOT
  # Recorder root pathname
  # :nocov:
  def self.root
    ROOT
  end
  # :nocov:

  module Tasks
    # :nocov:
    # @api private
    def self.install
      # Any default tasks are removed
      Rake::Task[:default].clear if Rake::Task.task_defined?(:default)
      Dir[Recorder.root.join("lib/tasks/*.rake")].each do |rake_file|
        load rake_file
      end

      if Rake::Task.task_defined?(:rubocop)
        Rake::Task.define_task(default: [:rubocop, :spec])
      else
        Rake::Task.define_task(default: [:spec])
      end
    end
    # :nocov:
  end
  # Define Rake tasks
  Tasks.install if defined?(Rake)

  require "csv"
  def self.string_field_converter
    @string_field_converter ||= lambda {|field|
      field.strip rescue field # rubocop:disable Style/RescueModifier
    }
  end

  def self.parse(delimited_record, delimiter: delimiter_for(delimited_record))
    CSV.parse(delimited_record,
              headers: true,
              return_headers: false,
              header_converters: :symbol,
              converters: [string_field_converter, :date],
              col_sep: delimiter,
              skip_blanks: true
             )
  end

  def self.delimiters
    @delimiters ||= ["|", ",", " "]
  end

  def self.delimiter_for(delimited_record)
    delimiters.find {|delimiter|
      first_row = CSV.new(delimited_record, col_sep: delimiter).each { |row|
        break row
      }
      first_row.size > 1
    }
  end

  class Builder
    attr_reader :records
    def initialize
      @records = []
    end

    def parse(delimited_record)
      records << Recorder.parse(delimited_record)
    end
  end
end
