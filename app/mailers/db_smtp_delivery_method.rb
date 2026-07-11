# Registered as ActionMailer delivery method :db_smtp. Reads SMTP
# credentials from SmtpSetting (admin-managed, DB-stored) at delivery
# time rather than from a static config file, so an admin can change
# them without a redeploy.
class DbSmtpDeliveryMethod
  attr_accessor :settings

  def initialize(values)
    @settings = values
  end

  def deliver!(mail)
    setting = SmtpSetting.instance
    raise "SMTP is not configured" unless setting.configured?

    Mail::SMTP.new(setting.to_mail_smtp_settings).deliver!(mail)
  end
end
