module MotionPlot
  class Line < Base

    attr_reader :layer_hosting_view, :graph, :series, :plot_space, :major_grid_line_style, :plots, :xaxis, :yaxis, :data_label_annotation

    attr_accessor :title, :legend_enabled, :plot_symbol, :curve_inerpolation, :axes

    def bootstrap(options)
      options.each_pair {|key, value|
        send("#{key}=", value) if(respond_to?("#{key}="))
      }

      @axes = {}
      if(options[:xAxis])
        @axes[:x] = Axis.new(options[:xAxis].merge(type: 'xaxis'))
      else
        @axes[:x] = Axis.new(type: 'xaxis', enabled: false)
      end

      if(options[:yAxis])
        @axes[:y] = Axis.new(options[:yAxis].merge(type: 'yaxis'))
      else
        @axes[:y] = Axis.new(type: 'yaxis', enabled: false)
      end

      @series = {}
      series = options[:series]
      series && series.each_with_index {|hash, index|
        @series[hash[:name]] = Series.new(hash)
      }

      if(options[:legend])
        @legend_enabled = options[:legend][:enabled] || false
      end

      if(@plot_symbol)
        @plot_symbol[:size] ||= 8.0
      end

      @plots = []
    end

    def initWithOptions(options, containerView:container)
      bootstrap(options)

      @layer_hosting_view = CPTGraphHostingView.alloc.initWithFrame([[0, 0], [container.frame.size.width, container.frame.size.height]])

      bounds = @layer_hosting_view.bounds

      # create and assign chart to the hosting view.
      @graph = CPTXYGraph.alloc.initWithFrame(bounds)
      @layer_hosting_view.hostedGraph = @graph

      add_chart_title(@title) if(@title)

      @graph.applyTheme(CPTTheme.themeNamed KCPTPlainWhiteTheme)

      default_padding
      
      @chart_layers                         = [NSNumber.numberWithInt(CPTGraphLayerTypePlots), NSNumber.numberWithInt(CPTGraphLayerTypeMajorGridLines), NSNumber.numberWithInt(CPTGraphLayerTypeMinorGridLines), NSNumber.numberWithInt(CPTGraphLayerTypeAxisLines), NSNumber.numberWithInt(CPTGraphLayerTypeAxisLabels), NSNumber.numberWithInt(CPTGraphLayerTypeAxisTitles)]
      @graph.topDownLayerOrder              = @chart_layers
      
      
      # add plot space
      add_plot_space

      # TODO - move it to base class
      @major_grid_line_style            = CPTMutableLineStyle.lineStyle
      @major_grid_line_style.lineWidth  = 0.75
      @major_grid_line_style.lineColor  = CPTColor.grayColor.colorWithAlphaComponent(0.25)

      axisSet                           = @graph.axisSet
      @xaxis                            = axisSet.xAxis
      @xaxis.majorGridLineStyle         = @major_grid_line_style
      @xaxis.minorTicksPerInterval      = 1

      if(@axes[:x])
        axis = @axes[:x]
        add_axis_title(@xaxis, axis.title)

        if(axis.labels)
          labels = axis.labels.each_with_index.map do |l, i|
            @xaxis.labelingPolicy = CPTAxisLabelingPolicyNone
            label                 = CPTAxisLabel.alloc.initWithText(l, textStyle: axis_label_style(axis.style))
            label.tickLocation    = CPTDecimalFromInt(i)
            label.offset          = 3.0
            label  
          end

          @xaxis.axisLabels = NSSet.setWithArray(labels)  
        end
      end

      # Setting up y-axis
      @yaxis                            = axisSet.yAxis
      @yaxis.majorGridLineStyle         = @major_grid_line_style
      @yaxis.minorTicksPerInterval      = 1
      @yaxis.labelingPolicy             = CPTAxisLabelingPolicyAutomatic

      if(@axes[:y])
        axis = @axes[:y]
        add_axis_title(@yaxis, axis.title)
        @yaxis.setLabelTextStyle(axis_label_style(axis.style))
      end

      # Create the lines
      @series.keys.each_with_index do |name, index|
        line                            = CPTScatterPlot.alloc.initWithFrame(CGRectNull)
        line.identifier                 = name

        line_style                      = line.dataLineStyle.mutableCopy
        line_style.lineWidth            = 3.0

        if(@series[name].color)
          line_style.lineColor          = @series[name].color.to_color.to_cpt_color
        else
          line_style.lineColor          = COLORS[index].to_color.to_cpt_color
        end

        line.dataLineStyle              = line_style
        line.dataSource                 = self
        line.delegate                   = self
        line.interpolation              = CPTScatterPlotInterpolationCurved if(@curve_inerpolation)

        add_plot_symbol(line, index) if(@plot_symbol)

        @graph.addPlot(line)
        @plots << line
      end

      add_legend if(@legend_enabled)

      add_xy_range

      @layer_hosting_view
    end

    def add_plot_space
      @plot_space                       = @graph.defaultPlotSpace
      @plot_space.delegate              = self
      @plot_space.allowsUserInteraction = true
    end

    def add_plot_symbol(line, index)
      symbol_style                          = CPTMutableLineStyle.lineStyle
      symbol_style.lineColor                = line.dataLineStyle.lineColor
      plot_symbol                           = MotionPlot::PlotSymbol[index]
      plot_symbol.fill                      = CPTFill.fillWithColor(line.dataLineStyle.lineColor, colorWithAlphaComponent:0.5)
      plot_symbol.lineStyle                 = symbol_style
      plot_symbol.size                      = CGSizeMake(@plot_symbol[:size].to_f, @plot_symbol[:size].to_f)
      line.plotSymbol                       = plot_symbol
      line.plotSymbolMarginForHitDetection  = 5.0
    end

    def add_xy_range
      @plot_space.scaleToFitPlots(@plots)
      x_range = @plot_space.xRange.mutableCopy
      y_range = @plot_space.yRange.mutableCopy

      # x_range.expandRangeByFactor(CPTDecimalFromDouble(1.01))
      # y_range.expandRangeByFactor(CPTDecimalFromDouble(1.01))

      # @plot_space.xRange = x_range
      # @plot_space.yRange = y_range
    end

    # This implementation of this method will put the line graph in a fix position so it won't be scrollable.
    def plotSpace(space, willChangePlotRangeTo:new_range, forCoordinate:coordinate)
      (coordinate == CPTCoordinateY) ? space.yRange : space.xRange
    end

    def scatterPlot(plot, plotSymbolWasSelectedAtRecordIndex:index)
      if(@data_label_annotation)
        @graph.plotAreaFrame.plotArea.removeAnnotation(@data_label_annotation)
        @data_label_annotation = nil
      end

      annotation_style                      = CPTMutableTextStyle.textStyle
      annotation_style.color                = CPTColor.blackColor
      annotation_style.fontSize             = 14.0
      annotation_style.fontName             = FONT_NAME

      y_value                               = @series[plot.identifier].data[index][0].round(2)
      text_layer                            = CPTTextLayer.alloc.initWithText(y_value.to_s, style:annotation_style)

      @data_label_annotation                = CPTPlotSpaceAnnotation.alloc.initWithPlotSpace(@graph.defaultPlotSpace, anchorPlotPoint:[index, y_value])
      @data_label_annotation.contentLayer   = text_layer
      @data_label_annotation.displacement   = CGPointMake(0.0, 20.0)

      @graph.plotAreaFrame.plotArea.addAnnotation(@data_label_annotation)
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