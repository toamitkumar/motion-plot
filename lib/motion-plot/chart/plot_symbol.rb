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

      ALIASES.each_pair do |key, value|
        define_method(key) do
          CPTPlotSymbol.send(value)
        end
      end

      alias_method :default, :rectangle

      def [](index)
        index = 0 if(index > 9)

        send(ALIASES.keys[index])
      end
    end
  end
end