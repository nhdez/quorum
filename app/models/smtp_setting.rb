class SmtpSetting < ApplicationRecord
  AUTHENTICATION_METHODS = %w[plain login cram_md5 none].freeze

  encrypts :password

  validates :authentication, inclusion: { in: AUTHENTICATION_METHODS }, allow_blank: true
  validates :port, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  def self.instance
    first_or_create!
  end

  def configured?
    address.present?
  end

  def to_mail_smtp_settings
    auth = authentication.presence
    auth = nil if auth == "none"

    {
      address: address,
      port: port,
      domain: domain,
      user_name: user_name,
      password: password,
      authentication: auth&.to_sym,
      enable_starttls_auto: enable_starttls_auto
    }.compact
  end
end
