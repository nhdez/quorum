class StorageSetting < ApplicationRecord
  encrypts :secret_access_key

  validates :force_path_style, inclusion: { in: [ true, false ] }

  def self.instance
    first_or_create!
  end

  def configured?
    bucket.present? && access_key_id.present? && secret_access_key.present?
  end

  def to_aws_options
    {
      region: region.presence || "us-east-1",
      access_key_id: access_key_id,
      secret_access_key: secret_access_key,
      endpoint: endpoint.presence,
      force_path_style: force_path_style
    }.compact
  end
end
