module MotionPlot
  class Bar < Base

    CPDBarWidth     = 0.25
    CPDBarInitialX  = 0.0

    def add_series
      bar_x = CPDBarInitialX

      horizontal_bar = (@orientation == "vertical") ? true : false

      @series.keys.each_with_index do |name, index|
        bar               = CPTBarPlot.tubularBarPlotWithColor(@series[name].color, horizontalBars: horizontal_bar)
        bar.barWidth      = CPTDecimalFromDouble(CPDBarWidth)
        bar.barOffset     = CPTDecimalFromDouble(bar_x)

        bar.identifier    = name

        _style            = CPTMutableLineStyle.alloc.init
        _style.lineWidth  = 0.5
        _style.lineColor  = CPTColor.lightGrayColor

        bar.lineStyle     = _style
        bar.dataSource    = self
        bar.delegate      = self

        @graph.addPlot(bar)
        @plots << bar

        animate(bar)

        bar_x += CPDBarWidth
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

    def numberOfRecordsForPlot(plot)
      @series[plot.identifier].data.size
    end

    def numberForPlot(plot, field:field_enum, recordIndex:index)
      data  = @series[plot.identifier].data

      (field_enum == CPTBarPlotFieldBarTip) ? data[index][0] : index
    end

    def barPlot(plot, barWasSelectedAtRecordIndex:index)
      if(@data_label and @data_label.annotation)
        @graph.plotAreaFrame.plotArea.removeAnnotation(@data_label.annotation)
        @data_label.annotation = nil
      end

      y_value = @series[plot.identifier].data[index][0].round(2)
      @graph.plotAreaFrame.plotArea.addAnnotation(@data_label.annotation_for(y_value, atCoordinate: index+CPTDecimalFloatValue(plot.barOffset), plotSpace: @graph.defaultPlotSpace))
    end

  end
end