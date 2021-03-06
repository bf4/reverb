require "swagger"
module Recorder
  class Schema
    def self.build
      builder = Swagger.builder
      builder.swagger = 2.0
      builder.info do |info|
        info.version = "1.0.0"
        info.title =  "Recorder reverb"
        info.description =  "coding challenge https://reverb.com/page/dev-challenge"
        info.termsOfService =  "TBD"
        info.contact =  {
          "name": "Benjamin Fleischer",
          "email": "github@benjaminfleischer.com",
          "url": "https://github.com/bf4/reverb"
        }
        info.license = {
          "name": "All rights reserved",
          "url": "http://example.com/"
        }
      end
      builder.host = "localhost:9292"
      builder.basePath = "/api"
      builder.schemes =  [
        "http"
      ]
      builder.consumes =  [
        "application/json"
      ]
      builder.produces =  [
        "application/json"
      ]
      builder.paths = {
        "/records": {
          "post": {
            "tags": [
              "Record Operations"
            ],
            "summary": "Add a record",
            "operationId": "addRecord",
            "description": "Adds the given line to the existing csv",
            "produces": [
              "application/json"
            ],
            "parameters": [
              {
                "name": "delimited_record",
                "in": "body",
                "description": "line to add",
                "required": true,
                "type": "file"
              }],
              "responses": {
                "200": {
                  "description": "A collection of records.",
                  "schema": {
                    "type": "array",
                    "items": {
                      "$ref": "#/definitions/Record"
                    }
                  }
                },
                "default": {
                  "description": "unexpected error",
                  "schema": {
                    "$ref": "#/definitions/ErrorModel"
                  }
                }
              }
          }
        }
      }
      version_header = {
        name: "Accept-Version",
        in: "header",
        type: "string",
        default: "v1",
        pattern: "v[\\d\\.]+",
        description: "The API version, e.g. 'v1'",
      }
      builder.paths.each do |_path, operations|
        operations.each do |_action, operation|
          next unless operation.respond_to?(:parameters)
          operation.parameters << version_header
        end
      end
      builder.definitions =  {
        "Record": {
          "required": [
            "delimited_record"
          ],
          "properties": {

            "delimited_record": {
              "items": {
                "type": "string"
              },
            }
          },
          "example": {
            "delimited_record": "HH David Male Ruby 1979-10-15"
          }
        },
        "ErrorModel": {
          "required": [
            "code",
            "message"
          ],
          "properties": {
            "code": {
              "type": "integer",
              "format": "int32"
            },
            "message": {
              "type": "string"
            }
          }
        }
      }
      api = builder.build
      api
    end

    def self.write(api)
      File.write(Recorder.root.join("public/api-docs.json"), JSON.pretty_generate(api))
    end
  end
end
