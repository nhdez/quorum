module Admin
  class StorageSettingsController < BaseController
    before_action :set_admin_nav
    before_action :set_storage_setting

    def edit
    end

    def update
      attrs = storage_setting_params
      attrs = attrs.except(:secret_access_key) if attrs[:secret_access_key].blank?

      if @storage_setting.update(attrs)
        redirect_to edit_admin_storage_settings_path, notice: "Storage settings saved."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def test
      setting = StorageSetting.instance
      raise "Storage is not configured" unless setting.configured?

      service = ActiveStorage::Service::S3Service.new(bucket: setting.bucket, **setting.to_aws_options)
      service.exist?("quorum-connection-test")

      redirect_to edit_admin_storage_settings_path, notice: "Connected to bucket \"#{setting.bucket}\" successfully."
    rescue StandardError => e
      redirect_to edit_admin_storage_settings_path, alert: "Connection failed: #{e.message}"
    end

    private

    def set_admin_nav
      @admin_nav_current = :storage_settings
    end

    def set_storage_setting
      @storage_setting = StorageSetting.instance
    end

    def storage_setting_params
      params.require(:storage_setting).permit(:endpoint, :region, :bucket, :access_key_id, :secret_access_key, :force_path_style)
    end
  end
end
