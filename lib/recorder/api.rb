#  curl \
#    -H "Accept-Version:v1" \
#    -H Accept:application/json \
#    -X POST \
#    -F "delimited_record=@spec/fixtures/record.csv" \
#    http://localhost:9292/api/records
require "grape"
require "grape-roar"
module Recorder
  class API < Grape::API
    version "v1", using: :accept_version_header
    format :json
    prefix :api

    def self.dao
      @dao ||= Recorder::Builder.new
    end

    helpers do
      def builder
        Recorder::API.dao
      end

      # @return [String] csv representation of table
      def json_table(table)
        table.to_csv
      end

      def table_from_params(params)
        errors = []
        delimited_record = params[:delimited_record]
        record = delimited_record["filename"] ? delimited_record.tempfile : delimited_record
        table = builder.parse(record).last
      rescue RuntimeError => e
        if e.message =~ /delimiter/
          errors << e.message
        else
          raise
        end
      ensure
        return [table, errors]
      end
    end

    resources :records do

      desc "Post a single data line in any of the supported formats"
      params do
        requires :delimited_record, desc: "The delimited record."
      end
      post do
        table, errors = table_from_params(params)
        if errors.empty?
          status 201
          { data: json_table(table) }
        else
          status 422
          { errors: {status: 422, title: "Could not parse record", messages: errors } }
        end
      end

      desc "Output 1: returns records sorted by gender"
      get "/gender" do
        status 200
        table = builder.records.last
        formatted_table = Recorder::Views.format(table, 1)
        { data: json_table(formatted_table) }
      end

      desc "Output 2: returns records sorted by birthdate "
      get "/birthdate" do
        status 200
        table = builder.records.last
        formatted_table = Recorder::Views.format(table, 2)
        { data: json_table(formatted_table) }
      end

      desc "Output 3: returns records sorted by name"
      get "/name" do
        status 200
        table = builder.records.last
        formatted_table = Recorder::Views.format(table, 3)
        { data: json_table(formatted_table) }
      end
    end
  end
end
