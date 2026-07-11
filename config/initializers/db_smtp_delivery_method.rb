Rails.application.config.to_prepare do
  ActionMailer::Base.add_delivery_method :db_smtp, DbSmtpDeliveryMethod
end
