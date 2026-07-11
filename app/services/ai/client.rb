module Ai
  class Client
    def initialize(anthropic_client: nil)
      @injected_client = anthropic_client
    end

    def structured_completion(system:, prompt:, schema:, max_tokens: 1024)
      setting = AiSetting.instance
      raise NotConfiguredError, "No Anthropic API key configured" unless setting.configured?

      response = client_for(setting).messages.create(
        model: setting.model_id,
        max_tokens: max_tokens,
        system: system,
        messages: [ { role: "user", content: prompt } ],
        output_config: { format: { type: "json_schema", schema: schema } }
      )

      text_block = response.content.find { |block| block.type == :text }
      JSON.parse(text_block.text)
    rescue Anthropic::Errors::APIError => e
      raise RequestError, e.message
    end

    private

    def client_for(setting)
      @injected_client || Anthropic::Client.new(api_key: setting.api_key)
    end
  end
end
