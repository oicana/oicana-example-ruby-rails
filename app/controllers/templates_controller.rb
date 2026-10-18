class TemplatesController < ApplicationController
  wrap_parameters false
  before_action :set_template, only: %i[compile preview]

  def index
    render json: TemplateRegistry.ids
  end

  def show
    path = TemplateRegistry.path(template_id)
    return render_error(:not_found, "Template not found") unless path

    send_file path, type: "application/zip", filename: "#{template_id}.zip"
  end

  def compile
    pdf = @template.export_pdf(**inputs)

    send_data pdf, type: "application/pdf", filename: "#{template_id}.pdf"
  end

  def preview
    png = @template.export_png(**inputs, mode: :development, pixels_per_pt: 1.0)

    send_data png, type: "image/png", disposition: "inline", filename: "#{template_id}.png"
  end

  def reset
    if TemplateRegistry.instance.remove(template_id)
      logger.info("Template '#{template_id}' removed from cache")
      head :no_content
    else
      logger.error("Template '#{template_id}' not found in cache")
      head :not_found
    end
  end

  private

  def template_id
    params[:id]
  end

  def set_template
    @template = TemplateRegistry.instance[template_id]
    render_error(:not_found, "Template '#{template_id}' not found!") unless @template
  end

  # JSON input values can be any JSON value.
  def inputs
    payload = params.permit(:id, jsonInputs: [ :key, :value, { value: {} } ], blobInputs: %i[key blobId]).to_h
    {
      json_inputs: payload.fetch(:jsonInputs, []).to_h { |input| [ input[:key], input[:value] ] },
      blob_inputs: payload.fetch(:blobInputs, []).to_h { |input| [ input[:key], BlobStore.fetch(input[:blobId]) ] }
    }
  end
end
