module MotionPlot
  class Axis
    attr_accessor :title, :enabled, :type, :labels, :style

    def initialize(args)
      args.each_pair {|key, value|
        send("#{key}=", value) if(respond_to?("#{key}="))
      }

      if(args[:title])
        @title = Title.new(args[:title])
      end

      if(args[:style])
        @style = Style.new(args[:style])
      else
        @style = Style.new
      end
    end

    def text_style
      text_style          = CPTMutableTextStyle.textStyle
      text_style.color    = @style.color
      text_style.fontName = @style.font_name
      text_style.fontSize = @style.font_size
      text_style
    end

    def is_x?
      type == "xaxis"
    end

    def is_y?
      type == "yaxis"
    end

    def enabled?
      enabled
    end
  end
end