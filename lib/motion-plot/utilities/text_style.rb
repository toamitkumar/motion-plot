module MotionPlot
  class TextStyle
    def self.cpt_text_style(style)
      text_style           = CPTMutableTextStyle.textStyle
      text_style.color     = style.color
      text_style.fontName  = style.font_name
      text_style.fontSize  = style.font_size

      text_style
    end
  end
end