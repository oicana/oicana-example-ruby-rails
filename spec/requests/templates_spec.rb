require "swagger_helper"

RSpec.describe "Templates", type: :request do
  let(:documented_payload) do
    RSpec.configuration.openapi_specs.dig("v1/swagger.yaml", :components, :schemas, :CompilationPayload, :example)
  end

  path "/templates" do
    get "List templates" do
      tags "template"
      description "Get a list of all template IDs known to the service."
      produces "application/json"

      response "200", "Success" do
        schema type: :array, items: { type: :string }

        run_test! do |response|
          expect(response.parsed_body).to eq(TemplateRegistry.ids)
        end
      end
    end
  end

  path "/templates/{id}" do
    parameter name: :id, in: :path, type: :string, description: "The identifier of the template to download.",
              example: "table"

    get "Download template" do
      tags "template"
      description "Download a packed template."
      produces "application/zip", "application/json"

      response "200", "Success" do
        let(:id) { "table" }

        run_test! do |response|
          expect(response.media_type).to eq("application/zip")
        end
      end

      response "404", "Template not found" do
        schema "$ref" => "#/components/schemas/ErrorResponse"
        let(:id) { "unknown" }

        run_test!
      end
    end
  end

  path "/templates/{id}/compile" do
    parameter name: :id, in: :path, type: :string, description: "The identifier of the template to compile.",
              example: "invoice"

    post "Compile template" do
      tags "template"
      description "Compile a template with given inputs."
      consumes "application/json"
      produces "application/pdf", "application/json"
      parameter name: :payload, in: :body, required: true,
                schema: { "$ref" => "#/components/schemas/CompilationPayload" }

      response "200", "Success" do
        let(:id) { "invoice" }
        let(:payload) { documented_payload }

        run_test! do |response|
          expect(response.media_type).to eq("application/pdf")
          expect(response.body).to start_with("%PDF")
        end
      end

      response "400", "Invalid inputs or a failed compilation" do
        schema "$ref" => "#/components/schemas/ErrorResponse"
        let(:id) { "table" }
        let(:payload) { { jsonInputs: [ { key: "unknown", value: {} } ] } }

        run_test! do |response|
          expect(response.parsed_body["message"]).to include("received invalid input")
        end
      end

      response "400", "Unknown blob" do
        schema "$ref" => "#/components/schemas/ErrorResponse"
        let(:id) { "invoice" }
        let(:payload) { { blobInputs: [ { key: "banner", blobId: "11111111-1111-1111-1111-111111111111" } ] } }

        run_test!
      end

      response "400", "Blob ID that is not a UUID" do
        schema "$ref" => "#/components/schemas/ErrorResponse"
        let(:id) { "invoice" }
        let(:payload) { { blobInputs: [ { key: "banner", blobId: "../config/master.key" } ] } }

        run_test!
      end

      response "404", "Template not found" do
        schema "$ref" => "#/components/schemas/ErrorResponse"
        let(:id) { "unknown" }
        let(:payload) { { jsonInputs: [] } }

        run_test!
      end
    end
  end

  path "/templates/{id}/preview" do
    parameter name: :id, in: :path, type: :string, description: "The identifier of the template to preview.",
              example: "invoice"

    post "Preview template" do
      tags "template"
      description "Generate a PNG preview of the template with given inputs."
      consumes "application/json"
      produces "image/png", "application/json"
      parameter name: :payload, in: :body, required: true,
                schema: { "$ref" => "#/components/schemas/CompilationPayload" }

      response "200", "Success" do
        let(:id) { "invoice" }
        let(:payload) { documented_payload }

        run_test! do |response|
          expect(response.media_type).to eq("image/png")
        end
      end

      response "404", "Template not found" do
        schema "$ref" => "#/components/schemas/ErrorResponse"
        let(:id) { "unknown" }
        let(:payload) { { jsonInputs: [] } }

        run_test!
      end
    end
  end

  path "/templates/{id}/reset" do
    parameter name: :id, in: :path, type: :string, description: "The identifier of the template to reset.",
              example: "table"

    post "Reset template" do
      tags "template"
      description "Remove a template from the cache and free it. The template is unavailable until the service restarts."

      # Resets the fonts template, which no other spec uses, since the registry is shared.
      response "204", "Template successfully removed from cache" do
        let(:id) { "fonts" }

        run_test! do
          post "/templates/fonts/compile", params: {}, as: :json
          expect(response).to have_http_status(:not_found)
        end
      end

      response "404", "Template not found in cache" do
        let(:id) { "unknown" }

        run_test!
      end
    end
  end
end
