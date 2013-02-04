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

    LEGEND_POSITION   = [
      CPTRectAnchorTopRight,
      CPTRectAnchorBottomLeft,
      CPTRectAnchorBottom,
      CPTRectAnchorBottomRight,
      CPTRectAnchorLeft,
      CPTRectAnchorRight,
      CPTRectAnchorTopLeft,
      CPTRectAnchorTop,
      CPTRectAnchorCenter
    ]

    FONT_NAME         = "Helvetica-Bold"

    def add_title
      @graph.title                    = title
      text_style                      = CPTMutableTextStyle.textStyle
      text_style.color                = CPTColor.blackColor
      text_style.fontName             = FONT_NAME
      @graph.titleTextStyle           = text_style
      @graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop
    end

    def add_legend
      @graph.legend               = CPTLegend.legendWithGraph(@graph)
      @graph.legend.fill          = CPTFill.fillWithColor(CPTColor.whiteColor)
      @graph.legend.cornerRadius  = 5.0
      @graph.legend.swatchSize    = CGSizeMake(25.0, 25.0)
      @graph.legendAnchor         = LEGEND_POSITION[0]
      @graph.legendDisplacement   = CGPointMake(0.0, 12.0)
    end

    def default_padding
      @graph.plotAreaFrame.masksToBorder    = true
      @graph.plotAreaFrame.borderLineStyle  = nil
      @graph.plotAreaFrame.paddingLeft      = 40.0
      @graph.plotAreaFrame.paddingTop       = 10.0
      @graph.plotAreaFrame.paddingRight     = 10.0
      @graph.plotAreaFrame.paddingBottom    = 30.0
    end
  end
end