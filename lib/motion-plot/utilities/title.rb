module MotionPlot
  class Title

    attr_accessor :text, :position, :style

    def initialize(options={})
      @text     = options[:text]
      @position = options[:position] || AnchorPosition.default
      @style    = Style.new(options)
    end

    def text_style
      text_style           = CPTMutableTextStyle.textStyle
      text_style.color     = @style.color
      text_style.fontName  = @style.font_name

      text_style
    end

  end
end