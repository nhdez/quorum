require "active_storage/service/s3_service"
require "active_storage/service/disk_service"

module ActiveStorage
  # Routes every Active Storage operation to a real S3Service built fresh
  # from StorageSetting (admin-managed, DB-stored) when configured, or
  # falls back to local disk otherwise. This is the same "read config
  # from the DB at call time" approach as DbSmtpDeliveryMethod — an
  # admin can point uploads at S3 (or any S3-compatible provider)
  # without a restart. Registered as the app's Active Storage service in
  # config/initializers/db_storage_service.rb (bypasses config/storage.yml
  # entirely, since that file is only read once at boot).
  class Service::DbConfigurableService < Service
    def initialize(**)
      @disk_service = Service::DiskService.new(root: Rails.root.join("storage").to_s)
    end

    delegate :upload, :update_metadata, :download, :download_chunk, :open, :compose,
      :delete, :delete_prefixed, :exist?, :url, :url_for_direct_upload,
      :headers_for_direct_upload, :public?, to: :active_service

    private

    def active_service
      setting = StorageSetting.instance
      setting.configured? ? build_s3_service(setting) : @disk_service
    end

    def build_s3_service(setting)
      Service::S3Service.new(bucket: setting.bucket, **setting.to_aws_options)
    end
  end
end
