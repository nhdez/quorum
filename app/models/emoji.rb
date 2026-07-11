# Shared curated emoji list — used by the Lexxy editor's :shortcode: prompt
# (see shared/_emoji_prompt partial) and by signature markdown rendering,
# so both places recognize the same shortcodes.
class Emoji
  LIST = {
    "smile" => "😀", "laugh" => "😂", "wink" => "😉", "love" => "😍", "thinking" => "🤔",
    "cry" => "😢", "angry" => "😡", "shocked" => "😱", "sleep" => "😴", "cool" => "😎",
    "eyeroll" => "🙄", "shrug" => "🤷", "thumbsup" => "👍", "thumbsdown" => "👎",
    "clap" => "👏", "praise" => "🙌", "handshake" => "🤝", "wave" => "👋", "pray" => "🙏",
    "muscle" => "💪", "heart" => "❤️", "fire" => "🔥", "hundred" => "💯", "star" => "⭐",
    "party" => "🎉", "rocket" => "🚀", "check" => "✅", "cross" => "❌", "warning" => "⚠️",
    "eyes" => "👀", "facepalm" => "🤦", "popcorn" => "🍿"
  }.freeze

  SHORTCODE_PATTERN = /:([a-z]+):/

  def self.replace_shortcodes(text)
    text.to_s.gsub(SHORTCODE_PATTERN) { |match| LIST[$1] || match }
  end
end
