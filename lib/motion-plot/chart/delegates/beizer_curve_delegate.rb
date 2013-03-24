module MotionPlot
  class BeizerCurveDelegate < BaseDelegate

    def numberOfRecordsForPlot(plot)
      step_size = @delegated_to.plot_options.line[:step_size] || 1
      p @delegated_to.plot_options.line[:data_size] / step_size
      @delegated_to.plot_options.line[:data_size] / step_size
    end

    # This implementation of this method will put the line graph in a fix position so it won't be scrollable.
    def plotSpace(space, willChangePlotRangeTo:new_range, forCoordinate:coordinate)
      (coordinate == CPTCoordinateY) ? space.yRange : space.xRange
    end

    def scatterPlot(plot, plotSymbolWasSelectedAtRecordIndex:index)
      if(@delegated_to.data_label and @delegated_to.data_label.annotation)
        @delegated_to.graph.plotAreaFrame.plotArea.removeAnnotation(@delegated_to.data_label.annotation)
        @delegated_to.data_label.annotation = nil
      end

      y_value = @delegated_to.series[plot.identifier].data[index].round(2)
      @delegated_to.graph.plotAreaFrame.plotArea.addAnnotation(@delegated_to.data_label.annotation_for(y_value, atCoordinate: [index, y_value], plotSpace: @delegated_to.graph.defaultPlotSpace))
    end

    def numberForPlot(plot, field:field_enum, recordIndex:index)

      case field_enum
      when CPTScatterPlotFieldY
        num = index
      when CPTScatterPlotFieldX
        p @delegated_to.series[plot.identifier].data

        num = @delegated_to.series[plot.identifier].data.call(index)
      end
      
      num
    end    
  
  end
end