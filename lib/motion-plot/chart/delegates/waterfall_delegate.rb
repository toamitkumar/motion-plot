module MotionPlot
  class WaterfallDelegate < BaseDelegate

    def numberOfRecordsForPlot(plot)
      @data_size = @delegated_to.series[plot.identifier].data.size + 1
    end

    def numberForPlot(plot, field:field_enum, recordIndex:index)
      case field_enum
      when CPTBarPlotFieldBarLocation
        index
      when CPTBarPlotFieldBarTip
        record_data = @delegated_to.series[plot.identifier].data[index]
        bar_tip_value(index, seriesData: @delegated_to.series[plot.identifier].data, startValue: record_data)
      when CPTBarPlotFieldBarBase
        bar_base_value(index, seriesData: @delegated_to.series[plot.identifier].data)
      end
    end

    def barPlot(plot, barWasSelectedAtRecordIndex:index)
      if(@delegated_to.data_label and @delegated_to.data_label.annotation)
        @delegated_to.graph.plotAreaFrame.plotArea.removeAnnotation(@delegated_to.data_label.annotation)
        @delegated_to.data_label.annotation = nil
      end

      data_index  = (index == @data_size - 1) ? (index - 1) : index
      data        = @delegated_to.series[plot.identifier].data
      y_value     = data[data_index].round(2)
      y_pos       = bar_tip_value(data_index, seriesData: data, startValue: y_value)
      y_value     = y_pos.round(2) if(index == @data_size - 1) # total bar of waterfall chart
      
      @delegated_to.graph.plotAreaFrame.plotArea.addAnnotation(@delegated_to.data_label.annotation_for(y_value, atCoordinate: [index+CPTDecimalFloatValue(plot.barOffset), y_pos], plotSpace: @delegated_to.graph.defaultPlotSpace))
    end

    protected
    def bar_base_value(data_index, seriesData: data)
      return 0 if(data_index == 0 || data_index == @data_size - 1)

      (0..data_index-1).inject(0) {|base, i| base + data[i] }
    end

    def bar_tip_value(data_index, seriesData: data, startValue: value)
      data_index = data_index - 1 if(data_index == @data_size - 1)

      return value if(data_index == 0)

      (0..data_index).inject(0) {|base, i| base + data[i] }
    end        

  end
end