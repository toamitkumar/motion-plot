module MotionPlot
  class Line < Base

    attr_reader :layer_hosting_view, :graph, :series, :plot_space, :major_grid_line_style, :plots, :xaxis, :yaxis, :data_label_annotation

    attr_accessor :title, :xlabels, :xtitle, :ytitle, :legend_enabled, :title_enabled, :data_label_enabled, :curve_inerpolation

    def bootstrap(options)
      options.each_pair {|key, value|
        send("#{key}=", value) if(respond_to?("#{key}="))
      }

      if(options[:xAxis])
        @xlabels = options[:xAxis][:labels]
      end

      if(options[:yAxis])

      end

      @series = {}
      series = options[:series]
      series && series.each_with_index {|hash, index|
        @series[hash[:name]] = Series.new(hash)
      }

      if(options[:legend])
        @legend_enabled = options[:legend][:enabled] || false
      end

      if(options[:datalabels])
        @data_label_enabled = options[:datalabels][:enabled] || false
      end

      @plots = []
    end

    def initWithOptions(options, containerView:container)
      bootstrap(options)

      @layer_hosting_view = CPTGraphHostingView.alloc.initWithFrame(container.frame)

      bounds = @layer_hosting_view.bounds

      # create and assign chart to the hosting view.
      @graph = CPTXYGraph.alloc.initWithFrame(bounds)
      @layer_hosting_view.hostedGraph = @graph

      add_title

      @graph.applyTheme(CPTTheme.themeNamed KCPTPlainWhiteTheme)

      default_padding
      
      @chart_layers                         = [NSNumber.numberWithInt(CPTGraphLayerTypePlots), NSNumber.numberWithInt(CPTGraphLayerTypeMajorGridLines), NSNumber.numberWithInt(CPTGraphLayerTypeMinorGridLines), NSNumber.numberWithInt(CPTGraphLayerTypeAxisLines), NSNumber.numberWithInt(CPTGraphLayerTypeAxisLabels), NSNumber.numberWithInt(CPTGraphLayerTypeAxisTitles)]
      @graph.topDownLayerOrder              = @chart_layers
      
      
      # add plot space
      add_plot_space

      @major_grid_line_style            = CPTMutableLineStyle.lineStyle
      @major_grid_line_style.lineWidth  = 0.75
      @major_grid_line_style.lineColor  = CPTColor.grayColor.colorWithAlphaComponent(0.25)

      axisSet                           = @graph.axisSet
      @xaxis                            = axisSet.xAxis
      @xaxis.majorGridLineStyle         = @major_grid_line_style
      @xaxis.minorTicksPerInterval      = 1

      if(@xtitle)
        @xaxis.title = @xtitle
        @xaxis.titleOffset = 30.0
      end

      if(@xlabels)
        labels = @xlabels.each_with_index.map do |l, i|
          @xaxis.labelingPolicy = CPTAxisLabelingPolicyNone
          label = CPTAxisLabel.alloc.initWithText(l, textStyle: @xaxis.labelTextStyle)
          label.tickLocation = CPTDecimalFromInt(i)
          label.offset = 5.0
          label  
        end

        @xaxis.axisLabels = NSSet.setWithArray(labels)
      end

      # Setting up y-axis
      @yaxis                            = axisSet.yAxis
      @yaxis.majorGridLineStyle         = @major_grid_line_style
      @yaxis.minorTicksPerInterval      = 1
      @yaxis.labelingPolicy             = CPTAxisLabelingPolicyAutomatic

      if(@ytitle)
        @yaxis.title = @ytitle
        @yaxis.titleOffset = 30.0
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

        add_data_labels(line, index) if(@data_label_enabled)

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

    def add_data_labels(line, index)
      symbol_style                          = CPTMutableLineStyle.lineStyle
      symbol_style.lineColor                = line.dataLineStyle.lineColor
      plot_symbol                           = CPTPlotSymbol.send(PLOTSYMBOLS[index])
      plot_symbol.fill                      = CPTFill.fillWithColor(line.dataLineStyle.lineColor, colorWithAlphaComponent:0.5)
      plot_symbol.lineStyle                 = symbol_style
      plot_symbol.size                      = CGSizeMake(8.0, 8.0)
      line.plotSymbol                       = plot_symbol
      line.plotSymbolMarginForHitDetection  = 5.0
    end

    def add_xy_range
      @plot_space.scaleToFitPlots(@plots)
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

      y_value                               = @series[plot.identifier].data[index].round(2)
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

      (field_enum == CPTScatterPlotFieldY) ? data[index] : index

      # if (field_enum == CPTScatterPlotFieldY) 
      #   num = data[index]
      # elsif (field_enum == CPTScatterPlotFieldX)
      #   num = index
      # end

      # num
    end

  end
end