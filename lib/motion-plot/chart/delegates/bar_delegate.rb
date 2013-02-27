module MotionPlot
  class BarDelegate

    # delegate :series, :to => :delegated_to

    def initialize(source)
      @delegated_to = source
    end

    def numberOfRecordsForPlot(plot)
      @delegated_to.series[plot.identifier].data.size
    end

    def numberForPlot(plot, field:field_enum, recordIndex:index)
      data  = @delegated_to.series[plot.identifier].data

      (field_enum == CPTBarPlotFieldBarTip) ? data[index] : index
    end

    def barPlot(plot, barWasSelectedAtRecordIndex:index)
      if(@delegated_to.data_label and @delegated_to.data_label.annotation)
        @delegated_to.graph.plotAreaFrame.plotArea.removeAnnotation(@delegated_to.data_label.annotation)
        @delegated_to.data_label.annotation = nil
      end

      y_value = @delegated_to.series[plot.identifier].data[index].round(2)
      @delegated_to.graph.plotAreaFrame.plotArea.addAnnotation(@delegated_to.data_label.annotation_for(y_value, atCoordinate: index+CPTDecimalFloatValue(plot.barOffset), plotSpace: @delegated_to.graph.defaultPlotSpace))
    end

  end
end