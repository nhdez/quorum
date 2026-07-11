require "test_helper"

class AiSettingTest < ActiveSupport::TestCase
  test "instance returns the same row on repeat calls" do
    first = AiSetting.instance
    second = AiSetting.instance

    assert_equal first.id, second.id
  end

  test "instance defaults model_id to the first available model" do
    setting = AiSetting.instance

    assert_equal AiSetting::AVAILABLE_MODELS.keys.first, setting.model_id
  end

  test "configured? is false when api_key is blank" do
    setting = AiSetting.new(api_key: nil)

    assert_not setting.configured?
  end

  test "configured? is true when api_key is present" do
    setting = AiSetting.new(api_key: "sk-ant-test")

    assert setting.configured?
  end

  test "encrypts api_key at rest" do
    setting = AiSetting.instance
    setting.update!(api_key: "sk-ant-secret")

    raw = ActiveRecord::Base.connection.select_value(
      "SELECT api_key FROM ai_settings WHERE id = '#{setting.id}'"
    )

    assert_not_equal "sk-ant-secret", raw
    assert_equal "sk-ant-secret", setting.reload.api_key
  end

  test "rejects a model_id outside the curated list" do
    setting = AiSetting.new(model_id: "gpt-4")

    assert_not setting.valid?
  end
end
