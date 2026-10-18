# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  config.openapi_root = Rails.root.join("swagger").to_s

  config.openapi_specs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "Oicana example",
        description: "Ruby on Rails example with Oicana",
        version: "1.0"
      },
      externalDocs: { url: "https://oicana.com/docs/", description: "General documentation for Oicana." },
      tags: [
        { name: "template",
          description: "Template API endpoints. Find used templates at https://github.com/oicana/oicana-example-templates." },
        { name: "certificates", description: "Create certificates" },
        { name: "blob", description: "Blob storage endpoints. Upload files (images, documents) to use as template inputs." }
      ],
      paths: {},
      servers: [ { url: "http://127.0.0.1:3007" } ],
      components: {
        schemas: {
          CompilationPayload: {
            type: :object,
            properties: {
              jsonInputs: { type: :array, items: { "$ref" => "#/components/schemas/JsonInput" } },
              blobInputs: { type: :array, items: { "$ref" => "#/components/schemas/BlobInput" } }
            },
            example: {
              jsonInputs: [
                { key: "invoice",
                  value: {
                    id: "2025-03-10t172205",
                    issuingDate: "2025-04-27",
                    deliveryDate: "2025-04-19",
                    dueDate: "2025-05-06",
                    biller: {
                      name: "Alex Johnson",
                      title: "Senior Consultant",
                      company: "Example Solutions GmbH",
                      "vat-id": "DE1234567",
                      iban: "DE89370400440532013000",
                      address: { country: "Germany", city: "Berlin", "postal-code": "10115", street: "Sample Street 23" }
                    },
                    recipient: {
                      name: "Maria Schmidt",
                      title: "IT Manager",
                      "vat-id": "DE7654321",
                      address: { country: "Germany", city: "Munich", "postal-code": "80331", street: "Business Avenue 1" }
                    },
                    items: [
                      { date: "2025-04-03", description: "Wireless keyboard", quantity: 4, price: 25 },
                      { date: "2025-04-03", description: "USB-C cable", quantity: 2, price: 45 },
                      { date: "2025-04-03", description: "Network infrastructure consultation", "dur-min": 120, price: 200 }
                    ]
                  } }
              ],
              blobInputs: [ { key: "banner", blobId: "00000000-0000-0000-0000-000000000000" } ]
            }
          },
          JsonInput: {
            type: :object,
            properties: {
              key: { type: :string, description: "The input key", example: "invoice" },
              value: { description: "Any JSON value, passed to the template as is" }
            },
            required: %w[key value]
          },
          BlobInput: {
            type: :object,
            properties: {
              key: { type: :string, description: "The input key for the blob", example: "banner" },
              blobId: { type: :string, format: :uuid, description: "UUID of the blob from the blob storage",
                        example: "00000000-0000-0000-0000-000000000000" }
            },
            required: %w[key blobId]
          },
          CreateCertificate: {
            type: :object,
            properties: {
              name: { type: :string, description: "Name to create the certificate for", example: "Jane Doe" }
            },
            required: %w[name]
          },
          UploadResponse: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid, description: "The UUID assigned to the uploaded blob",
                    example: "550e8400-e29b-41d4-a716-446655440000" }
            },
            required: %w[id]
          },
          ErrorResponse: {
            type: :object,
            properties: { message: { type: :string } },
            required: %w[message]
          }
        }
      }
    }
  }

  config.openapi_format = :yaml
end
