require "rails_helper"

RSpec.describe "Home", type: :request do
  it "links to the swagger documentation" do
    get "/"

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq("text/html")
    expect(response.body).to include("/api-docs")
  end

  it "serves the swagger documentation" do
    get "/api-docs/v1/swagger.yaml"

    expect(response).to have_http_status(:ok)
  end
end
