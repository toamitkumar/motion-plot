module MotionPlot
  class Bar < Base

    attr_reader :data_hash

    DEFAULT_OPTIONS = {
      width: 0.25
    }

    CPDBarWidth     = 0.25
    CPDBarInitialX  = 0.0

    def plot_type
      "bar"
    end

    def add_series
      @stacking           = @plot_options ? @plot_options.bar[:stacking] : nil

      bar_x               = CPDBarInitialX
      @data_hash          = {}
      horizontal_bar      = (@orientation == "vertical") ? true : false
      @delegate_object    = case @stacking
      when "normal"
        StackBarDelegate.new(self)
      when "percent"
      else
        BarDelegate.new(self)
      end

      @series.keys.each_with_index do |name, index|
        bar               = CPTBarPlot.tubularBarPlotWithColor(@series[name].color, horizontalBars: horizontal_bar)
        bar.barWidth      = CPTDecimalFromDouble(CPDBarWidth)
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

        bar_x += CPDBarWidth
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

    # def numberOfRecordsForPlot(plot)
    #   @series[plot.identifier].data.size
    # end

    # def numberForPlot(plot, field:field_enum, recordIndex:index)
    #   # data  = @series[plot.identifier].data

    #   case field_enum
    #   when CPTBarPlotFieldBarLocation
    #     index
    #   when CPTBarPlotFieldBarTip
    #     plot_index = @series[plot.identifier].index
    #     record_data = @series[plot.identifier].data[index]
    #     bar_tip_value(plot_index, recordIndex:index, startValue:record_data)
    #   when CPTBarPlotFieldBarBase
    #     plot_index = @series[plot.identifier].index
    #     bar_base_value(plot_index, recordIndex:index)
    #   end

    #   # (field_enum == CPTBarPlotFieldBarTip) ? data[index] : index
    # end

    # def barPlot(plot, barWasSelectedAtRecordIndex:index)
    #   if(@data_label and @data_label.annotation)
    #     @graph.plotAreaFrame.plotArea.removeAnnotation(@data_label.annotation)
    #     @data_label.annotation = nil
    #   end

    #   y_value = @series[plot.identifier].data[index].round(2)
    #   @graph.plotAreaFrame.plotArea.addAnnotation(@data_label.annotation_for(y_value, atCoordinate: index+CPTDecimalFloatValue(plot.barOffset), plotSpace: @graph.defaultPlotSpace))
    # end

  end
end