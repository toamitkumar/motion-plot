module MotionPlot
  class Base

    attr_reader :layer_hosting_view, :graph, :series, :plot_space, :major_grid_line_style, :plots, :xaxis, :yaxis, :title

    attr_accessor :legend_enabled, :plot_symbol, :axes, :theme, :data_label, :orientation

    def bootstrap(options)
      options.each_pair {|key, value|
        send("#{key}=", value) if(respond_to?("#{key}="))
      }

      if(options[:title])
        @title = Title.new(options[:title])
      end

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
        @series[hash[:name]] = Series.new(hash.merge(index: index))
      }

      if(options[:legend])
        @legend_enabled = options[:legend][:enabled] || false
      end

      if(options[:data_label])
        @data_label = DataLabel.new(options[:data_label])
      end

      if(@plot_symbol)
        @plot_symbol = PlotSymbol.new(options[:plot_symbol])
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

      @graph.applyTheme(@theme || Theme.default)

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
            label                 = CPTAxisLabel.alloc.initWithText(l, textStyle: axis.text_style)
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
        @yaxis.setLabelTextStyle(axis.text_style)
      end

      # Create the lines
      add_series

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
      line.plotSymbol                       = @plot_symbol.symbol_for(line, atIndex: index)
      line.plotSymbolMarginForHitDetection  = 5.0
    end

    def add_xy_range
      @plot_space.scaleToFitPlots(@plots)
      x_range = @plot_space.xRange.mutableCopy
      y_range = @plot_space.yRange.mutableCopy

      x_range.expandRangeByFactor(CPTDecimalFromDouble(1.03))
      y_range.expandRangeByFactor(CPTDecimalFromDouble(1.03))

      @plot_space.xRange = x_range
      @plot_space.yRange = y_range
    end

    def add_chart_title(title)
      @graph.title                      = title.text
      @graph.titleTextStyle             = title.text_style
      @graph.titlePlotAreaFrameAnchor   = title.position
    end

    def add_axis_title(axis, title)
      axis.title            = title.text
      axis.titleTextStyle   = title.text_style
      axis.titleOffset      = title.style.offset
    end

    def add_legend
      @graph.legend               = CPTLegend.legendWithGraph(@graph)
      @graph.legend.fill          = CPTFill.fillWithColor(CPTColor.whiteColor)
      @graph.legend.cornerRadius  = 5.0
      @graph.legend.swatchSize    = CGSizeMake(25.0, 25.0)
      @graph.legendAnchor         = AnchorPosition.default
      @graph.legendDisplacement   = CGPointMake(0.0, 0.0)
    end

    def default_padding
      @graph.plotAreaFrame.masksToBorder    = false
      @graph.plotAreaFrame.borderLineStyle  = nil
      @graph.plotAreaFrame.paddingLeft      = 50.0
      @graph.plotAreaFrame.paddingTop       = 10.0
      @graph.plotAreaFrame.paddingRight     = 20.0
      @graph.plotAreaFrame.paddingBottom    = 20.0


      @graph.paddingLeft                    = 5.0
      @graph.paddingRight                   = 0.0
      @graph.paddingTop                     = 10.0
      @graph.paddingBottom                  = 10.0
    end
  end
end