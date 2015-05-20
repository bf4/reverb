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

    helpers do
      def builder
        @builder ||= Recorder::Builder.new
      end

      # @return [String] csv representation of table
      def json_table(table)
        table.to_csv.chomp
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
    end
  end
end
