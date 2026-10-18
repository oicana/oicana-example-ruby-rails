class ApplicationController < ActionController::API
  rescue_from Oicana::Error, with: :render_oicana_error
  rescue_from BlobStore::NotFoundError do |error|
    render_error(:bad_request, error.message)
  end

  private

  def render_error(status, message)
    render json: { message: message }, status: status
  end

  def render_oicana_error(error)
    status, message =
      case error
      when Oicana::InvalidInputError
        [ :bad_request, "Template '#{template_id}' received invalid input: #{error.message}" ]
      when Oicana::CompilationError
        [ :bad_request, "Template '#{template_id}' failed to compile with given inputs: #{error.message}" ]
      when Oicana::ClosedError
        # The template was reset while this request was waiting for it.
        [ :not_found, "Template '#{template_id}' not found!" ]
      else
        [ :internal_server_error, "Template '#{template_id}' failed to export!\n#{error.message}" ]
      end
    logger.error(message)
    render_error(status, message)
  end
end
