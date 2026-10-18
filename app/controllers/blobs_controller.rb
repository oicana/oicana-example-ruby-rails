class BlobsController < ApplicationController
  def create
    file = params.expect(:file)
    return render_error(:bad_request, "No file field provided") unless file.respond_to?(:read)

    render json: { id: BlobStore.add(file.read) }
  rescue SystemCallError => e
    logger.error("Failed to store the blob: #{e.message}")
    render_error(:internal_server_error, "Failed to save file")
  end
end
