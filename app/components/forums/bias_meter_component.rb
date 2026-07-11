module Forums
  class BiasMeterComponent < ApplicationComponent
    def initialize(value:, posts_analyzed:, history: [])
      @value = value
      @posts_analyzed = posts_analyzed
      @history = history
    end

    attr_reader :value, :posts_analyzed

    def label
      case value
      when 0...15 then "Strongly Left"
      when 15...40 then "Leaning Left"
      when 40..60 then "Center"
      when 60..85 then "Leaning Right"
      else "Strongly Right"
      end
    end

    def color
      case value
      when 0...15 then "#2a56a8"
      when 15...40 then "#3f66a8"
      when 40..60 then "#6b6b6b"
      when 60..85 then "#a85050"
      else "#b8302f"
      end
    end

    def sparkline_points
      return "" if history.empty?

      last_index = history.length - 1
      history.each_with_index.map do |v, i|
        x = (i.to_f / last_index * 300).round
        y = (36 - (v / 100.0) * 36).round
        "#{x},#{y}"
      end.join(" ")
    end

    private

    attr_reader :history
  end
end
