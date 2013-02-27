module MotionPlot
  class Line < Base

    attr_accessor :curve_inerpolation

    DEFAULT_OPTIONS = {
      width: 2.0
    }

    def plot_type
      "line"
    end

    def add_series
      @series.keys.each_with_index do |name, index|
        line                  = CPTScatterPlot.alloc.initWithFrame(CGRectNull)
        line.identifier       = name

        line_style            = line.dataLineStyle.mutableCopy
        line_style.lineWidth  = @series[name].width

        line_style.lineColor  = @series[name].color

        line.dataLineStyle    = line_style
        line.dataSource       = self
        line.delegate         = self
        line.interpolation    = CPTScatterPlotInterpolationCurved if(@curve_inerpolation)

        add_plot_symbol(line, index) if(@plot_symbol)

        @graph.addPlot(line)
        @plots << line
      end
    end

    # This implementation of this method will put the line graph in a fix position so it won't be scrollable.
    def plotSpace(space, willChangePlotRangeTo:new_range, forCoordinate:coordinate)
      (coordinate == CPTCoordinateY) ? space.yRange : space.xRange
    end

    def scatterPlot(plot, plotSymbolWasSelectedAtRecordIndex:index)
      if(@data_label and @data_label.annotation)
        @graph.plotAreaFrame.plotArea.removeAnnotation(@data_label.annotation)
        @data_label.annotation = nil
      end

      y_value = @series[plot.identifier].data[index][0].round(2)
      @graph.plotAreaFrame.plotArea.addAnnotation(@data_label.annotation_for(y_value, atCoordinate: index, plotSpace: @graph.defaultPlotSpace))
    end

    def numberOfRecordsForPlot(plot)
      @series[plot.identifier].data.size
    end

    def numberForPlot(plot, field:field_enum, recordIndex:index)
      data  = @series[plot.identifier].data

      (field_enum == CPTScatterPlotFieldY) ? data[index][0] : index
    end
  end
end