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
        bar_tip_value(index, recordIndex:index, seriesData: @delegated_to.series[plot.identifier].data, startValue: record_data)
      when CPTBarPlotFieldBarBase
        bar_base_value(index, recordIndex:index, seriesData: @delegated_to.series[plot.identifier].data)
      end
    end

    protected
    def bar_base_value(data_index, recordIndex:index, seriesData: data)
      return 0 if(data_index == 0 || data_index == @data_size - 1)

      (0..data_index-1).inject(0) {|base, i| base + data[i] }
    end

    def bar_tip_value(data_index, recordIndex:index, seriesData: data, startValue: value)
      data_index = data_index - 1 if(data_index == @data_size - 1)

      return value if(data_index == 0)

      (0..data_index).inject(0) {|base, i| base + data[i] }
    end        

  end
end