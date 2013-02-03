module MotionPlot
  class Base

    COLORS = ['4572A7', 'AA4643', '89A54E', '80699B', '3D96AE', 'DB843D', '92A8CD', 'A47D7C', 'B5CA92']

    PLOTSYMBOLS = [
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

    LEGEND_POSITION = [
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
  end
end