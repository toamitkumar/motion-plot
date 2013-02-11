module MotionPlot
  class Base

    COLORS            = ['4572A7', 'AA4643', '89A54E', '80699B', '3D96AE', 'DB843D', '92A8CD', 'A47D7C', 'B5CA92']

    PLOTSYMBOLS       = [
      "rectanglePlotSymbol", 
      "plusPlotSymbol", 
      "starPlotSymbol", 
      "diamondPlotSymbol", 
      "trianglePlotSymbol", 
      "pentagonPlotSymbol", 
      "hexagonPlotSymbol", 
      "dashPlotSymbol", 
      "snowPlotSymbol"
    ]

    FONT_NAME         = "Helvetica-Bold"

    def add_chart_title(title)
      @graph.title                      = title[:text]
      style                             = title.dup.delete_if {|k, v| k == :text}
      style                             = Style.new(style)
      text_style                        = CPTMutableTextStyle.textStyle
      text_style.color                  = style.color
      text_style.fontName               = style.font_name
      
      @graph.titleTextStyle             = text_style
      @graph.titlePlotAreaFrameAnchor   = title[:position] || AnchorPosition.default
    end

    def add_axis_title(axis, title)
      axis.title                        = title[:text]
      style                             = title.dup.delete_if {|k, v| k == :text}
      style                             = Style.new(style)
      text_style                        = CPTMutableTextStyle.textStyle
      text_style.color                  = style.color
      text_style.fontName               = style.font_name
      
      axis.titleTextStyle               = text_style
      axis.titleOffset                  = style.offset
    end

    def axis_label_style(style)
      _style                            = Style.new(style)
      text_style                        = CPTMutableTextStyle.textStyle
      text_style.color                  = _style.color
      text_style.fontName               = _style.font_name
      text_style.fontSize               = _style.font_size
      text_style
    end

    def add_legend
      @graph.legend               = CPTLegend.legendWithGraph(@graph)
      @graph.legend.fill          = CPTFill.fillWithColor(CPTColor.whiteColor)
      @graph.legend.cornerRadius  = 5.0
      @graph.legend.swatchSize    = CGSizeMake(25.0, 25.0)
      @graph.legendAnchor         = LEGEND_POSITION[0]
      @graph.legendDisplacement   = CGPointMake(0.0, 0.0)
    end

    def default_padding
      @graph.plotAreaFrame.masksToBorder    = false
      @graph.plotAreaFrame.borderLineStyle  = nil
      @graph.plotAreaFrame.paddingLeft      = 50.0
      @graph.plotAreaFrame.paddingTop       = 10.0
      @graph.plotAreaFrame.paddingRight     = 20.0
      @graph.plotAreaFrame.paddingBottom    = 20.0


      @graph.paddingLeft                    = 5.0
      @graph.paddingRight                   = 0.0
      @graph.paddingTop                     = 10.0
      @graph.paddingBottom                  = 10.0
    end
  end
end