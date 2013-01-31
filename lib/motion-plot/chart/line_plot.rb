class LinePlot

  attr_reader :layer_hosting_view, :graph, :series

  attr_accessor :title, :xlabels, :ytitle, :legend_enabled, :series 

  def initialize(options)
    options.each_pair {|key, value|
      send("#{key}=", value) if(respond_to?("#{key}="))
    }
  end

  def initWithOptions(options, containerView:container)
    # line_plot = self.new(options)
    @sample_data = [6000, 3000, 4500, 2000, 3400, 2100, 1000]
    @sample_years = ["2010", "2011", "2012", "2013", "2014", "2015", "2016"]

    @layer_hosting_view = CPTGraphHostingView.alloc.initWithFrame(container.frame)

    bounds = @layer_hosting_view.bounds

    # create and assign chart to the hosting view.
    @graph = CPTXYGraph.alloc.initWithFrame(bounds)
    layer_hosting_view.hostedGraph = @graph

    # graph.applyTheme(CPTTheme.themeNamed KCPTDarkGradientTheme)
    # self.theme = CPTTheme.themeNamed KCPTDarkGradientTheme
    @graph.applyTheme(CPTTheme.themeNamed KCPTPlainWhiteTheme)
    
    @graph.plotAreaFrame.masksToBorder = false
    
    @graph.paddingLeft = 90.0
    @graph.paddingTop = 50.0
    @graph.paddingRight = 20.0
    @graph.paddingBottom = 60.0

    @chart_layers = [NSNumber.numberWithInt(CPTGraphLayerTypePlots), NSNumber.numberWithInt(CPTGraphLayerTypeMajorGridLines), NSNumber.numberWithInt(CPTGraphLayerTypeMinorGridLines), NSNumber.numberWithInt(CPTGraphLayerTypeAxisLines), NSNumber.numberWithInt(CPTGraphLayerTypeAxisLabels), NSNumber.numberWithInt(CPTGraphLayerTypeAxisTitles)]
    @graph.topDownLayerOrder = @chart_layers
    
    
    # Add plot space for horizontal line charts
    add_plot_space

    major_x_grid_line_style = CPTMutableLineStyle.lineStyle
    major_x_grid_line_style.lineWidth = 1.0
    major_x_grid_line_style.lineColor = CPTColor.grayColor.colorWithAlphaComponent(0.25)

    axisSet = @graph.axisSet
    x = axisSet.xAxis
    x.labelingPolicy = CPTAxisLabelingPolicyNone
    x.majorGridLineStyle = major_x_grid_line_style
    x.majorIntervalLength = CPTDecimalFromString("1")
    x.minorTicksPerInterval = 1

    x.orthogonalCoordinateDecimal = CPTDecimalFromString("0")
    x.title = "Years"
    x.timeOffset = 30.0
    x_label_exclusion_range = CPTPlotRange.alloc.init
    x_label_exclusion_range.location = CPTDecimalFromInt(0)
    x_label_exclusion_range.length = CPTDecimalFromInt(0)
    x.labelExclusionRanges = [x_label_exclusion_range]

    labels = @sample_years.each_with_index.map do |product, index|
      label = CPTAxisLabel.alloc.initWithText(product, textStyle: x.labelTextStyle)
      label.tickLocation = CPTDecimalFromInt(index)
      label.offset = 5.0
      label
    end
    x.axisLabels = NSSet.setWithArray(labels)

    # Setting up y-axis
    major_y_grid_line_style = CPTMutableLineStyle.lineStyle
    major_y_grid_line_style.lineWidth = 1.0
    major_y_grid_line_style.dashPattern =  [5.0, 5.0]
    major_y_grid_line_style.lineColor = CPTColor.lightGrayColor.colorWithAlphaComponent(0.25)
    
    
    y = axisSet.yAxis
    y.majorGridLineStyle = major_y_grid_line_style
    y.majorIntervalLength = CPTDecimalFromString("1000")
    y.minorTicksPerInterval = 1
    y.orthogonalCoordinateDecimal = CPTDecimalFromString("0")
    y.title = "Consumer Spending"
    y_label_exclusion_range = CPTPlotRange.alloc.init
    y_label_exclusion_range.location = CPTDecimalFromInt(0)
    y_label_exclusion_range.length = CPTDecimalFromInt(0)
    y.labelExclusionRanges = [y_label_exclusion_range]

    # Create a high plot area
    high_plot = CPTScatterPlot.alloc.init
    high_plot.identifier = "HighPlot"
    
    high_line_style = high_plot.dataLineStyle.mutableCopy
    high_line_style.lineWidth = 2
    high_line_style.lineColor = CPTColor.colorWithComponentRed(0.50, green:0.67, blue:0.65, alpha:1.0)
    high_plot.dataLineStyle = high_line_style
    high_plot.dataSource = self
  
    area_fill = CPTFill.fillWithColor(CPTColor.colorWithComponentRed(0.50, green:0.67, blue:0.65, alpha:0.4))
    high_plot.areaFill = area_fill
    high_plot.areaBaseValue = CPTDecimalFromString("0")
    @graph.addPlot(high_plot)

    @selected_coordination = 2

    @touch_plot = CPTScatterPlot.alloc.initWithFrame(CGRectNull)
    @touch_plot.identifier = "LinePlot"
    @touch_plot.dataSource = self
    @touch_plot.delegate = self
    applyTouchPlotColor
    @graph.addPlot(@touch_plot)
  end

  def add_plot_space
    plot_space = @graph.defaultPlotSpace
    plot_space.delegate = self
    plot_space.allowsUserInteraction = true
    y_plot_range = CPTPlotRange.alloc.init
    y_plot_range.location = CPTDecimalFromInt(0)
    y_plot_range.length = CPTDecimalFromInt(10000)
    plot_space.yRange = y_plot_range # CPTPlotRange.plotRangeWithLocation(CPTDecimalFromInt(0), length:CPTDecimalFromInt(10000))
    x_plot_range = CPTPlotRange.alloc.init
    x_plot_range.location = CPTDecimalFromInt(0)
    x_plot_range.length = CPTDecimalFromInt(6)
    plot_space.xRange = x_plot_range
  end

  # Highlight the touch plot when the user holding tap on the line symbol.
  def applyHighLightPlotColor(plot)
    selected_plot_color = CPTColor.redColor
    
    symbol_line_style = CPTMutableLineStyle.lineStyle
    symbol_line_style.lineColor = selected_plot_color
    
    plot_symbol = CPTPlotSymbol.ellipsePlotSymbol
    plot_symbol.fill = CPTFill.fillWithColor(selected_plot_color)
    plot_symbol.lineStyle = symbol_line_style
    plot_symbol.size = CGSizeMake(15.0, 15.0)
    
    plot.plotSymbol = plot_symbol
    
    selected_line_style = CPTMutableLineStyle.lineStyle
    selected_line_style.lineColor = CPTColor.yellowColor
    selected_line_style.lineWidth = 5.0
    
    plot.dataLineStyle = selected_line_style
  end

  # This implementation of this method will put the line graph in a fix position so it won't be scrollable.
  def plotSpace(space, willChangePlotRangeTo:new_range, forCoordinate:coordinate)
    (coordinate == CPTCoordinateY) ? space.yRange : space.xRange
  end

  # This method is called when user touch & drag on the plot space.
  def plotSpace(space, shouldHandlePointingDeviceDraggedEvent:event, atPoint:point)
    point_in_plot_area = @graph.convertPoint(point, toLayer:@graph.plotAreaFrame)

    new_point = Pointer.new(NSDecimal.type, 2)
    @graph.defaultPlotSpace.plotPoint(new_point, forPlotAreaViewPoint:point_in_plot_area)
    NSDecimalRound(new_point, new_point, 0, NSRoundPlain)
    x = NSDecimalNumber.decimalNumberWithDecimal(new_point[0]).intValue

    p x

    x = if(x < 0) 
          0 
        elsif(x > @sample_data.size)
          @sample_data.size
        end

    if (@touch_plot_selected)
      @selected_coordination = x
      
      # if(self.delegate.respond_to?(:indexLocation))
      self.delegate.indexLocation(self, indexLocation:x)

      @touch_plot.reloadData
    end
    true
  end

  def plotSpace(space, shouldHandlePointingDeviceDownEvent:event, atPoint:point)
    true
  end

  def plotSpace(space, shouldHandlePointingDeviceUpEvent:event, atPoint:point)
    applyTouchPlotColor
    @touch_plot_selected = false
    true
  end

  def scatterPlot(plot, plotSymbolWasSelectedAtRecordIndex:index)
    if(plot.identifier == "LinePlot")

    end
  end

  def numberOfRecordsForPlot(plot)
    (plot.identifier == "LinePlot") ? 3 : @sample_data.size
  end

  def numberForPlot(plot, field:field_enum, recordIndex:index)
    if (plot.identifier == "HighPlot")
      if (field_enum == CPTScatterPlotFieldY) 
        num = @sample_data[index]
      elsif (field_enum == CPTScatterPlotFieldX)
        num = index
      end
    elsif (plot.identifier == "LinePlot")
      if (field_enum == CPTScatterPlotFieldY) 
        case index
        when 0
          num = 0
        when 2
          num = 9700
        else
          num = @sample_data[@selected_coordination]
        end
      elsif(field_enum == CPTScatterPlotFieldX)
        num = @selected_coordination
      end
    end

    num
  end

end