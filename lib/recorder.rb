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

  # TECHDEBT: Move into own file
  class Builder
    attr_reader :records
    def initialize
      @records = []
    end

    def parse(delimited_record)
      records << Recorder.parse(delimited_record)
    end

    # Destructively combine all records into one table
    # by appending the first table with rows removed from the other tables
    def combine_records!
      return records if records.size < 2
      table = records.shift
      records.each do |record|
        record.size.times.with_index do |index|
          table << record.delete(index)
        end
      end
      @records = [table]
    end
  end

  # TECHDEBT: Move into own file
  module Views
    class View
      def self.sort_order
        fail "#{caller[0]} needs to implement #{__callee__}"
      end

      def self.format(table)
        data_table = table.to_a
        headers = data_table.shift
        dob_index = headers.index(:dateofbirth)
        date_format = "%m/%d/%Y".freeze
        data_table.each do |row|
          row[dob_index] = row[dob_index].strftime(date_format)
        end
        data_table.sort! {|row1, row2|
          sort_order.reduce(nil) {|comparison, (field_name, direction)|
            field_index = headers.index(field_name)
            break comparison unless comparison.nil? || comparison.zero?
            case direction
            when :asc
              row1[field_index] <=> row2[field_index]
            when :desc
              row2[field_index] <=> row1[field_index]
            else
              fail "Unknown sort direction #{direction.inspect}"
            end
          }
        }
      end
    end

    class Output1 < View
      def self.sort_order
        @sort_order ||= [[:gender, :asc], [:lastname, :asc]]
      end
    end

    class Output2 < View
      def self.sort_order
        @sort_order ||= [[:dateofbirth, :asc]]
      end
    end

    class Output3 < View
      def self.sort_order
        @sort_order ||= [[:lastname, :desc]]
      end
    end
  end
end
