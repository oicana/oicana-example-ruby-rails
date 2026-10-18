require "swagger_helper"

RSpec.describe "Blobs", type: :request do
  path "/blobs" do
    post "Upload blob" do
      tags "blob"
      description "Upload a blob (image, file, etc.) to use as template input. " \
                  "Returns a UUID to reference the blob in compilation requests."
      consumes "multipart/form-data"
      produces "application/json"
      parameter name: :file, in: :formData, required: true,
                schema: { type: :object, required: %w[file],
                          properties: { file: { type: :string, format: :binary, description: "The file to upload" } } }

      response "200", "Blob uploaded successfully" do
        schema "$ref" => "#/components/schemas/UploadResponse"
        let(:file) { Rack::Test::UploadedFile.new(StringIO.new("test content"), "text/plain", original_filename: "test.txt") }

        run_test! do |response|
          id = response.parsed_body["id"]
          expect(BlobStore.fetch(id)).to eq("test content")
          File.delete(BlobStore.directory.join(id))
        end
      end

      response "400", "Invalid file upload" do
        let(:file) { "" }

        run_test!
      end
    end
  end
end
