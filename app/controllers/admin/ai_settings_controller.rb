module Admin
  class AiSettingsController < BaseController
    class_attribute :ai_client_factory, default: -> { Ai::Client.new }

    before_action :set_admin_nav
    before_action :set_ai_setting

    def edit
    end

    def update
      attrs = ai_setting_params
      attrs = attrs.except(:api_key) if attrs[:api_key].blank?

      if @ai_setting.update(attrs)
        redirect_to edit_admin_ai_settings_path, notice: "AI settings saved."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def test
      ai_client_factory.call.structured_completion(
        system: "You respond only with the requested JSON.",
        prompt: 'Reply with {"ok": true}.',
        schema: { type: "object", properties: { ok: { type: "boolean" } }, required: [ "ok" ], additionalProperties: false },
        max_tokens: 64
      )
      redirect_to edit_admin_ai_settings_path, notice: "Connected — model responded successfully."
    rescue Ai::NotConfiguredError
      redirect_to edit_admin_ai_settings_path, alert: "No API key configured yet."
    rescue Ai::RequestError => e
      redirect_to edit_admin_ai_settings_path, alert: "Connection failed: #{e.message}"
    end

    private

    def set_admin_nav
      @admin_nav_current = :settings
    end

    def set_ai_setting
      @ai_setting = AiSetting.instance
    end

    def ai_setting_params
      params.require(:ai_setting).permit(:api_key, :model_id)
    end
  end
end
