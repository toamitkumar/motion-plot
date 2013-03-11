module MotionPlot
  class Title

    attr_accessor :text, :position, :style

    def initialize(options={})
      @text     = options[:text]
      @position = options[:position] || AnchorPosition.default
      @style    = Style.new(options)
    end

    def text_style
      TextStyle.cpt_text_style(@style)
    end

  end
end