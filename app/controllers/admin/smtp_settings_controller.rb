module Admin
  class SmtpSettingsController < BaseController
    before_action :set_admin_nav
    before_action :set_smtp_setting

    def edit
    end

    def update
      attrs = smtp_setting_params
      attrs = attrs.except(:password) if attrs[:password].blank?

      if @smtp_setting.update(attrs)
        redirect_to edit_admin_smtp_settings_path, notice: "SMTP settings saved."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def test
      setting = SmtpSetting.instance
      from_address = setting.from_address.presence || setting.user_name
      to_address = current_user.email

      mail = Mail.new do
        from from_address
        to to_address
        subject "Quorum SMTP Test"
        body "This is a test email from Quorum's SMTP settings page."
      end

      DbSmtpDeliveryMethod.new({}).deliver!(mail)
      redirect_to edit_admin_smtp_settings_path, notice: "Test email sent to #{to_address}."
    rescue StandardError => e
      redirect_to edit_admin_smtp_settings_path, alert: "Send failed: #{e.message}"
    end

    private

    def set_admin_nav
      @admin_nav_current = :smtp_settings
    end

    def set_smtp_setting
      @smtp_setting = SmtpSetting.instance
    end

    def smtp_setting_params
      params.require(:smtp_setting).permit(:address, :port, :domain, :user_name, :password, :authentication, :enable_starttls_auto, :from_address)
    end
  end
end
