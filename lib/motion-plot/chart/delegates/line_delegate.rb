module MotionPlot
  class LineDelegate < BaseDelegate

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

      if(@delegated_to.subscribed_events)
        @delegated_to.subscribed_events.delegate_event(:symbol_selected, withData: {plot: plot, index: index})
      end
    end

    def numberForPlot(plot, field:field_enum, recordIndex:index)
      data  = @delegated_to.series[plot.identifier].data

      (field_enum == CPTScatterPlotFieldY) ? data[index] : index
    end

  end
end