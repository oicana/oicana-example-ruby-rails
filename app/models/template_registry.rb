# Oicana cannot compile in a process forked from one that already compiled a template,
# so every process loads its own templates on first use instead of during boot.
class TemplateRegistry
  VERSIONS = {
    "accessibility" => "0.1.0",
    "certificate" => "0.1.0",
    "dependency" => "0.1.0",
    "fonts" => "0.1.0",
    "invoice" => "0.1.0",
    "invoice_zugferd" => "0.1.0",
    "minimal" => "0.1.0",
    "table" => "0.1.0",
    "multi_input" => "0.1.0"
  }.freeze

  MUTEX = Mutex.new
  private_constant :MUTEX

  class << self
    def instance
      MUTEX.synchronize do
        @instance = nil unless @pid == Process.pid
        @pid = Process.pid
        @instance ||= new
      end
    end

    def ids
      VERSIONS.keys
    end

    def path(id)
      version = VERSIONS[id]
      Rails.root.join("templates", "#{id}-#{version}.zip") if version
    end
  end

  def initialize
    @mutex = Mutex.new
    @templates = VERSIONS.each_with_object({}) do |(id, version), templates|
      templates[id] = Oicana::Template.new(File.binread(self.class.path(id)))
      Rails.logger.info("Warmed-up #{id} v#{version}")
    rescue SystemCallError, Oicana::Error => e
      Rails.logger.error("Failed to warm up template #{id} v#{version}: #{e.message}")
    end
  end

  def [](id)
    @mutex.synchronize { @templates[id] }
  end

  def remove(id)
    template = @mutex.synchronize { @templates.delete(id) }
    template&.close
    !template.nil?
  end
end
