module FallacyDetection
  # Scans a single post (ForumThread or ThreadReply) for logical fallacies
  # via a single structured Ai::Client call, and replaces that post's
  # existing FallacyFlag rows with a fresh set. Informational only — never
  # touches moderation state.
  class Scanner
    RESPONSE_SCHEMA = {
      type: "array",
      items: {
        type: "object",
        properties: {
          "fallacy_key" => { type: "string" },
          "excerpt" => { type: "string" },
          "confidence" => { type: "number" }
        },
        required: %w[fallacy_key excerpt confidence],
        additionalProperties: false
      }
    }.freeze

    def initialize(post, ai_client: Ai::Client.new)
      @post = post
      @ai_client = ai_client
    end

    def call
      forum = post.fallacy_scan_forum
      definitions = FallacyDefinition.all.select { |definition| definition.enabled_for?(forum) }
      return if definitions.empty?

      body_text = post.body.to_plain_text
      return if body_text.blank?

      results = @ai_client.structured_completion(
        system: system_prompt(definitions),
        prompt: body_text,
        schema: RESPONSE_SCHEMA
      )

      definitions_by_key = definitions.index_by(&:key)

      flags = results.filter_map do |result|
        definition = definitions_by_key[result["fallacy_key"]]
        next unless definition
        next if result["confidence"].to_f < definition.confidence_threshold_for(forum)

        {
          flaggable_type: post.class.name,
          flaggable_id: post.id,
          fallacy_definition_id: definition.id,
          excerpt: result["excerpt"],
          confidence: result["confidence"],
          created_at: Time.current
        }
      end

      post.fallacy_flags.destroy_all
      FallacyFlag.insert_all!(flags) if flags.any?
    rescue Ai::NotConfiguredError
      nil # No API key set yet — feature silently no-ops rather than erroring posts.
    end

    private

    attr_reader :post

    def system_prompt(definitions)
      fragments = definitions.map(&:detection_prompt_fragment).join("\n\n")

      <<~PROMPT
        You are a logical fallacy detector for a political discussion forum. You are informational only — you never moderate or judge the truth of a claim, only whether a fallacious reasoning pattern is present.

        Analyze the post text for the following fallacies:

        #{fragments}

        Return a JSON array. Each element identifies one fallacy instance found, with the exact fallacy_key, the excerpt of text it applies to (quoted verbatim from the post), and your confidence from 0.0 to 1.0. If no fallacies are present, return an empty array.
      PROMPT
    end
  end
end
