module MotionPlot
  class PlotSymbol

    ALIASES = {
      :rectangle  => "rectanglePlotSymbol",
      :plus       => "plusPlotSymbol",
      :star       => "starPlotSymbol",
      :diamond    => "diamondPlotSymbol",
      :triangle   => "trianglePlotSymbol",
      :pentagon   => "pentagonPlotSymbol",
      :hexagon    => "hexagonPlotSymbol",
      :dash       => "dashPlotSymbol",
      :snow       => "snowPlotSymbol"
    }

    class << self
      def method_missing(m, *args, &block)
        method_name = m == :default ? :rectangle : m

        raise unless(ALIASES.keys.include?(method_name))        

        CPTPlotSymbol.send(ALIASES[method_name])
      end

      def [](index)
        index = 0 if(index > 9)

        send(ALIASES.keys[index])
      end
    end
  end
end