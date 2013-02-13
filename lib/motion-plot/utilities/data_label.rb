module MotionPlot
  class DataLabel
    
    DEFAULTS = {
      displacement: [0.0, 12.0]
    }.merge(Style::DEFAULTS)

    attr_accessor :annotation

    def initialize(options={})
      @attributes = DEFAULTS.merge(options)
      @style      = Style.new(@attributes)
    end

    def style
      _style          = CPTMutableTextStyle.textStyle
      _style.color    = @style.color
      _style.fontSize = @style.font_size
      _style.fontName = @style.font_name

      _style
    end

    def displacement
      @attributes[:displacement]
    end

    def annotation_for(value, atCoordinate: index, plotSpace: plot_space)
      @annotation               = CPTPlotSpaceAnnotation.alloc.initWithPlotSpace(plot_space, anchorPlotPoint:[index, value])
      text_layer                = CPTTextLayer.alloc.initWithText(value.to_s, style:style)
      @annotation.contentLayer  = text_layer
      @annotation.displacement  = @attributes[:displacement]

      @annotation
    end


  end
end