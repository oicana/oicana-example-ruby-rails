class CertificatesController < ApplicationController
  def create
    template = TemplateRegistry.instance[template_id]
    unless template
      logger.error("Certificate template not found!")
      return render_error(:internal_server_error, "Certificate template not found!")
    end

    certificate = params.expect(certificate: [ :name ]).to_h
    pdf = template.export_pdf(json_inputs: { "certificate" => certificate })

    send_data pdf, type: "application/pdf", filename: "certificate.pdf"
  end

  private

  def template_id
    "certificate"
  end
end
