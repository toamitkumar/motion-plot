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
      TextStyle.cpt_text_style(@style)
    end

    def displacement
      @attributes[:displacement]
    end

    def annotation_for(value, atCoordinate: coordinate, plotSpace: plot_space)
      @annotation               = CPTPlotSpaceAnnotation.alloc.initWithPlotSpace(plot_space, anchorPlotPoint:coordinate)
      @annotation.contentLayer  = annotation_text_style(value)
      @annotation.displacement  = @attributes[:displacement]

      @annotation
    end

    def annotation_text_style(value)
      CPTTextLayer.alloc.initWithText(value.to_s, style:style)
    end

  end
end