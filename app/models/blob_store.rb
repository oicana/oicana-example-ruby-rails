module BlobStore
  UUID_FORMAT = /\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/

  class NotFoundError < StandardError
    def initialize(id)
      super("Blob with id #{id} not found. Please use an ID of a blob that was previously uploaded.")
    end
  end

  @blobs = {}
  @mutex = Mutex.new

  class << self
    def directory
      Rails.root.join("blobs")
    end

    def fetch(id)
      id = id.to_s.downcase
      raise NotFoundError, id unless UUID_FORMAT.match?(id)

      @mutex.synchronize { @blobs[id] } || load(id)
    end

    def add(data)
      id = SecureRandom.uuid
      FileUtils.mkdir_p(directory)
      File.binwrite(directory.join(id), data)
      @mutex.synchronize { @blobs[id] = data }
      Rails.logger.info("Stored blob #{id} to disk and cache")
      id
    end

    private

    def load(id)
      data = File.binread(directory.join(id))
      @mutex.synchronize { @blobs[id] = data }
      Rails.logger.info("Loaded blob #{id} from disk and cached it")
      data
    rescue SystemCallError => e
      Rails.logger.warn("Failed to read blob #{id}: #{e.message}")
      raise NotFoundError, id
    end
  end
end
