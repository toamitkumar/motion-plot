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

    attr_accessor :enabled, :size

    def initialize(options={})
      options.each_pair {|key, value|
        send("#{key}=", value) if(respond_to?("#{key}="))
      }
    end

    def symbol_for(plot, atIndex:index)
      _style            = CPTMutableLineStyle.lineStyle
      _style.lineColor  = plot.dataLineStyle.lineColor
      symbol            = MotionPlot::PlotSymbol[index]
      symbol.fill       = CPTFill.fillWithColor(plot.dataLineStyle.lineColor, colorWithAlphaComponent:0.5)
      symbol.lineStyle  = _style
      symbol.size       = CGSizeMake(size.to_f, size.to_f)

      symbol
    end

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