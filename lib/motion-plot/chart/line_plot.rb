module MotionPlot
  class Line < Base

    def add_series
      @delegate_object = if(@plot_options and @plot_options.line[:beizer]) 
        BeizerCurveDelegate.new(self) 
      else
        LineDelegate.new(self)
      end

      @series.keys.each_with_index do |name, index|
        line                  = CPTScatterPlot.alloc.initWithFrame(CGRectNull)
        line.identifier       = name

        line_style            = line.dataLineStyle.mutableCopy
        line_style.lineWidth  = @series[name].width

        line_style.lineColor  = @series[name].color

        line.dataLineStyle    = line_style
        line.dataSource       = @delegate_object
        line.delegate         = @delegate_object
        line.interpolation    = CPTScatterPlotInterpolationCurved if(@plot_options and @plot_options.line[:curve_inerpolation])

        add_plot_symbol(line, @series[name].plot_symbol.symbol_for(line)) if(@series[name].plot_symbol)

        @graph.addPlot(line)
        @plots << line
      end
    end

    def default_padding
      line_series.style.paddings_for(@graph)
      line_series.style.plot_area.add_style(@graph.plotAreaFrame)
    end

    def line_series
      @series[plot_identifier]
    end

    def plot_identifier
      @series.keys.select{|k| @series[k].type == plot_type}.first
    end

    protected
    def default_style
      {
        width: 2.0
      }
    end    

    def plot_type
      "line"
    end

  end
end