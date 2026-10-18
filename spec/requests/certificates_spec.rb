require "swagger_helper"

RSpec.describe "Certificates", type: :request do
  path "/certificates" do
    post "Create certificate" do
      tags "certificates"
      description "Create a certificate"
      consumes "application/json"
      produces "application/pdf", "application/json"
      parameter name: :certificate, in: :body, required: true,
                schema: { "$ref" => "#/components/schemas/CreateCertificate" }

      response "200", "The compiled PDF certificate" do
        let(:certificate) { { name: "Test User" } }

        run_test! do |response|
          expect(response.media_type).to eq("application/pdf")
        end
      end

      response "400", "Missing name" do
        let(:certificate) { {} }

        run_test!
      end
    end
  end
end
