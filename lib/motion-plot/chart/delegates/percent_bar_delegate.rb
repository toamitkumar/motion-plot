module MotionPlot
  class PercentBarDelegate

    def initialize(source)
      @delegated_to = source
      @number_of_plots = @delegated_to.series.keys.size
    end

    def numberOfRecordsForPlot(plot)
      @delegated_to.series[plot.identifier].data.size
    end

    def numberForPlot(plot, field:field_enum, recordIndex:index)
      case field_enum
      when CPTBarPlotFieldBarLocation
        index
      when CPTBarPlotFieldBarTip
        plot_index = @delegated_to.series[plot.identifier].index
        record_data = @delegated_to.series[plot.identifier].data[index]
        bar_tip_value(plot_index, recordIndex:index, startValue:record_data)
      when CPTBarPlotFieldBarBase
        plot_index = @delegated_to.series[plot.identifier].index
        bar_base_value(plot_index, recordIndex:index)
      end
    end

    def barPlot(plot, barWasSelectedAtRecordIndex:index)
      if(@delegated_to.data_label and @delegated_to.data_label.annotation)
        @delegated_to.graph.plotAreaFrame.plotArea.removeAnnotation(@delegated_to.data_label.annotation)
        @delegated_to.data_label.annotation = nil
      end

      y_value     = (@delegated_to.series[plot.identifier].data[index].round(2) / total_sum_at_index(index)) * 100
      plot_index  = @delegated_to.series[plot.identifier].index
      y_pos       = (0..plot_index).inject(0) {|base, i| base + (@delegated_to.data_hash[i][index] / total_sum_at_index(index)) * 100 }
      
      @delegated_to.graph.plotAreaFrame.plotArea.addAnnotation(@delegated_to.data_label.annotation_for("#{y_value} %", atCoordinate: [index+CPTDecimalFloatValue(plot.barOffset), y_pos], plotSpace: @delegated_to.graph.defaultPlotSpace))
    end

    protected
    def bar_base_value(plot_index, recordIndex:index)
      return 0 if(plot_index == 0)

      (0..plot_index-1).inject(0) {|base, i| base + (@delegated_to.data_hash[i][index] / total_sum_at_index(index))*100 }
    end

    def bar_tip_value(plot_index, recordIndex:index, startValue:value)
      return (value / total_sum_at_index(index))*100 if(plot_index == 0)

      (0..plot_index).inject(0) {|base, i| base + (@delegated_to.data_hash[i][index] / total_sum_at_index(index))*100 }
    end

    def total_sum_at_index(index)
      total ||= (0..@number_of_plots-1).inject(0) {|total, i| total + @delegated_to.data_hash[i][index]}

      total
    end

  end
end