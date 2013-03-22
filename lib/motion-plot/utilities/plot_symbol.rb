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

    attr_accessor :enabled, :size, :type

    def initialize(options={})
      options.each_pair {|key, value|
        send("#{key}=", value) if(respond_to?("#{key}="))
      }

      @type = options[:type] ? self.class.send(options[:type]) : MotionPlot::PlotSymbol[options[:index]]
    end

    def symbol_for(plot)
      _style            = CPTMutableLineStyle.lineStyle
      _style.lineColor  = plot.dataLineStyle.lineColor
      symbol            = @type
      symbol.fill       = CPTFill.fillWithColor(plot.dataLineStyle.lineColor, colorWithAlphaComponent:0.5)
      symbol.lineStyle  = _style
      symbol.size       = CGSizeMake(size.to_f, size.to_f)

      symbol
    end

    def size
      @size || 8
    end
  end
end