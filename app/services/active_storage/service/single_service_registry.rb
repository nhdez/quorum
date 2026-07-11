module ActiveStorage
  # ActiveStorage::Blob validates service_name against Blob.services (an
  # object responding to #fetch(name) { ... }) and resolves the record's
  # own #service the same way. This app only ever has one active service
  # (DbConfigurableService), so rather than building the full YAML-driven
  # Service::Registry, this just always returns it regardless of the name
  # asked for — including on the miss path, since Blob's own validation
  # calls services.fetch(service_name) { errors.add(...) } and we don't
  # want that block invoked.
  class Service::SingleServiceRegistry
    def initialize(service)
      @service = service
    end

    def fetch(_name)
      @service
    end
  end
end
