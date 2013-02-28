module MotionPlot
  class StackBarDelegate

    # consign :series, :to => :delegated_to

    def initialize(source)
      @delegated_to = source
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

      y_value     = @delegated_to.series[plot.identifier].data[index].round(2)
      plot_index  = @delegated_to.series[plot.identifier].index
      y_pos       = (0..plot_index).inject(0) {|base, i| base + @delegated_to.data_hash[i][index]}
      
      @delegated_to.graph.plotAreaFrame.plotArea.addAnnotation(@delegated_to.data_label.annotation_for(y_value, atCoordinate: [index+CPTDecimalFloatValue(plot.barOffset), y_pos], plotSpace: @delegated_to.graph.defaultPlotSpace))
    end

    protected
    def bar_base_value(plot_index, recordIndex:index)
      return 0 if(plot_index == 0)

      (0..plot_index-1).inject(0) {|base, i| base + @delegated_to.data_hash[i][index] }
    end

    def bar_tip_value(plot_index, recordIndex:index, startValue:value)
      return value if(plot_index == 0)

      (0..plot_index).inject(0) {|base, i| base + @delegated_to.data_hash[i][index] }
    end

  end
end