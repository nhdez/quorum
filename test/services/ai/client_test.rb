require "test_helper"

module Ai
  class ClientTest < ActiveSupport::TestCase
    class FakeTextBlock
      attr_reader :type, :text

      def initialize(text)
        @type = :text
        @text = text
      end
    end

    class FakeMessage
      attr_reader :content

      def initialize(text)
        @content = [ FakeTextBlock.new(text) ]
      end
    end

    class FakeMessagesResource
      def initialize(response: nil, error: nil)
        @response = response
        @error = error
      end

      def create(**)
        raise @error if @error

        @response
      end
    end

    class FakeAnthropicClient
      attr_reader :messages

      def initialize(response: nil, error: nil)
        @messages = FakeMessagesResource.new(response: response, error: error)
      end
    end

    test "raises NotConfiguredError when no api_key is saved" do
      AiSetting.instance.update!(api_key: nil)

      error = assert_raises(Ai::NotConfiguredError) do
        Ai::Client.new.structured_completion(
          system: "sys", prompt: "hi", schema: { type: "object" }
        )
      end

      assert_match(/API key/, error.message)
    end

    test "parses a structured JSON response into a Hash" do
      AiSetting.instance.update!(api_key: "sk-ant-test")
      fake_message = FakeMessage.new('{"fallacy_detected": true}')
      fake_client = FakeAnthropicClient.new(response: fake_message)

      result = Ai::Client.new(anthropic_client: fake_client).structured_completion(
        system: "sys", prompt: "hi", schema: { type: "object" }
      )

      assert_equal({ "fallacy_detected" => true }, result)
    end

    test "wraps an Anthropic API error into RequestError" do
      AiSetting.instance.update!(api_key: "sk-ant-test")
      api_error = Anthropic::Errors::APIError.new(
        url: URI("https://api.anthropic.com/v1/messages"),
        status: 429,
        body: nil,
        request: nil,
        response: nil,
        message: "rate limited"
      )
      fake_client = FakeAnthropicClient.new(error: api_error)

      error = assert_raises(Ai::RequestError) do
        Ai::Client.new(anthropic_client: fake_client).structured_completion(
          system: "sys", prompt: "hi", schema: { type: "object" }
        )
      end

      assert_match(/rate limited/, error.message)
    end
  end
end
