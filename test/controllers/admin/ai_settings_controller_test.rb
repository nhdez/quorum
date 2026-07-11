require "test_helper"

module Admin
  class AiSettingsControllerTest < ActionDispatch::IntegrationTest
    class FakeSuccessClient
      def structured_completion(**)
        { "ok" => true }
      end
    end

    class FakeFailureClient
      def structured_completion(**)
        raise Ai::RequestError, "invalid x-api-key"
      end
    end

    def sign_in_as_admin
      admin = User.create!(email: "aiadmin@example.com", password: "password123", password_confirmation: "password123", confirmed_at: Time.current)
      admin.add_role(:admin)
      post user_session_path, params: { user: { email: admin.email, password: "password123" } }
      admin
    end

    def with_ai_client_factory(factory)
      original = Admin::AiSettingsController.ai_client_factory
      Admin::AiSettingsController.ai_client_factory = factory
      yield
    ensure
      Admin::AiSettingsController.ai_client_factory = original
    end

    test "redirects guests to the login page" do
      get edit_admin_ai_settings_url
      assert_redirected_to new_user_session_path
    end

    test "shows the current model selection" do
      sign_in_as_admin
      AiSetting.instance.update!(model_id: "claude-sonnet-5")

      get edit_admin_ai_settings_url

      assert_response :success
      assert_select "option[selected][value=?]", "claude-sonnet-5"
    end

    test "updates the model and api_key" do
      sign_in_as_admin

      patch admin_ai_settings_url, params: { ai_setting: { api_key: "sk-ant-newkey", model_id: "claude-haiku-4-5" } }

      assert_redirected_to edit_admin_ai_settings_path
      setting = AiSetting.instance
      assert_equal "claude-haiku-4-5", setting.model_id
      assert_equal "sk-ant-newkey", setting.api_key
    end

    test "a blank api_key on update preserves the existing key" do
      sign_in_as_admin
      AiSetting.instance.update!(api_key: "sk-ant-existing")

      patch admin_ai_settings_url, params: { ai_setting: { api_key: "", model_id: "claude-haiku-4-5" } }

      assert_equal "sk-ant-existing", AiSetting.instance.api_key
      assert_equal "claude-haiku-4-5", AiSetting.instance.model_id
    end

    test "test connection reports success" do
      sign_in_as_admin
      AiSetting.instance.update!(api_key: "sk-ant-existing")

      with_ai_client_factory(-> { FakeSuccessClient.new }) do
        post test_admin_ai_settings_url
      end

      assert_redirected_to edit_admin_ai_settings_path
      assert_match(/Connected/, flash[:notice])
    end

    test "test connection reports failure" do
      sign_in_as_admin
      AiSetting.instance.update!(api_key: "sk-ant-existing")

      with_ai_client_factory(-> { FakeFailureClient.new }) do
        post test_admin_ai_settings_url
      end

      assert_redirected_to edit_admin_ai_settings_path
      assert_match(/invalid x-api-key/, flash[:alert])
    end
  end
end
