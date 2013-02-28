module MotionPlot
  class Bar < Base

    attr_reader :data_hash

    CPDBarInitialX  = 0.0

    def add_series
      @stacking           = @plot_options ? @plot_options.bar[:stacking] : nil

      bar_x               = CPDBarInitialX
      @data_hash          = {}
      horizontal_bar      = (@orientation == "vertical") ? true : false
      @delegate_object    = case @stacking
      when "normal"
        StackBarDelegate.new(self)
      when "percent"
        PercentBarDelegate.new(self)
      else
        BarDelegate.new(self)
      end

      @series.keys.each_with_index do |name, index|
        bar               = CPTBarPlot.tubularBarPlotWithColor(@series[name].color, horizontalBars: horizontal_bar)
        bar.barWidth      = CPTDecimalFromDouble(@series[name].width)
        bar.barOffset     = CPTDecimalFromDouble(bar_x) unless(@stacking)

        bar.identifier    = name

        _style            = CPTMutableLineStyle.alloc.init
        _style.lineWidth  = 0.5
        _style.lineColor  = CPTColor.lightGrayColor

        bar.lineStyle     = _style
        bar.dataSource    = @delegate_object
        bar.delegate      = @delegate_object
        bar.barBasesVary  = @stacking ? true : false

        @graph.addPlot(bar)
        @plots << bar

        animate(bar)

        bar_x += @series[name].width
        @data_hash[index] = @series[name].data
      end
    end

    def animate(bar)
      bar.anchorPoint             = [0.0, 0.0]
      scale_direction             = (@orientation == "vertical") ? "transform.scale.x" : "transform.scale.y"
      scaling                     = CABasicAnimation.animationWithKeyPath(scale_direction)
      scaling.fromValue           = 0.0
      scaling.toValue             = 1.0
      scaling.duration            = 1.0
      scaling.removedOnCompletion = false
      scaling.fillMode            = KCAFillModeBackwards

      bar.addAnimation(scaling, forKey:"scaling")
    end

    protected
    def default_style
      {
        width: 0.25 
      }
    end

    def plot_type
      "bar"
    end

  end
end