# Overrides Active Storage's configured service (config.active_storage.service,
# resolved from config/storage.yml) with our DB-driven router, so an admin can
# turn on S3-compatible object storage from Admin > Object Storage without a
# redeploy. Left untouched in test — fixtures/tests keep using the plain
# :test disk service from config/storage.yml.
Rails.application.config.to_prepare do
  unless Rails.env.test?
    service = ActiveStorage::Service::DbConfigurableService.new
    service.name = :db_configurable

    ActiveStorage::Blob.services = ActiveStorage::Service::SingleServiceRegistry.new(service)
    ActiveStorage::Blob.service = service
  end
end
