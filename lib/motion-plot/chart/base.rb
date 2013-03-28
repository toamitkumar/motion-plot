module MotionPlot
  class Base

    attr_reader :layer_hosting_view, :graph, :series, :plot_space, :major_grid_line_style, :plots, :xaxis, :yaxis, :title, :subscribed_events

    attr_accessor :legend, :axes, :theme, :data_label, :plot_options

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

      if(@plot_options)
        @plot_options = PlotOptions.new(@plot_options)
      end

      @series = {}
      series = options[:series]
      series && series.each_with_index {|hash, index|
        hash.reverse_merge!({
          index: index, 
          defaults: default_style, 
          plot_options: @plot_options, 
          type: self.plot_type,
          plot_symbol: options[:plot_symbol]
        })
        @series[hash[:name]] = Series.new(hash)
      }

      if(options[:legend])
        @legend = Legend.new(options[:legend])
      end

      if(options[:data_label])
        @data_label = DataLabel.new(options[:data_label])
      end

      if(options[:events])
        @subscribed_events = Events.new(options[:events], self.plot_type)
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

      @major_grid_line_style            = CPTMutableLineStyle.lineStyle
      @major_grid_line_style.lineWidth  = 0.75
      @major_grid_line_style.lineColor  = CPTColor.grayColor.colorWithAlphaComponent(0.25)

      axisSet                           = @graph.axisSet

      # Setting up x-axis
      if(@axes[:x].enabled?)
        axis                          = @axes[:x]
        @xaxis                        = axisSet.xAxis
        @xaxis.majorGridLineStyle     = @major_grid_line_style
        @xaxis.minorTicksPerInterval  = 1

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
      if(@axes[:y].enabled?)
        @yaxis                            = axisSet.yAxis
        @yaxis.majorGridLineStyle         = @major_grid_line_style
        @yaxis.minorTicksPerInterval      = 1
        @yaxis.labelingPolicy             = CPTAxisLabelingPolicyAutomatic

        axis = @axes[:y]
        add_axis_title(@yaxis, axis.title)

        if(axis.labels)
          labels = axis.labels.each_with_index.map do |l, i|
            @yaxis.labelingPolicy = CPTAxisLabelingPolicyNone
            label                 = CPTAxisLabel.alloc.initWithText(l, textStyle: axis.text_style)
            label.tickLocation    = CPTDecimalFromInt(i)
            label.offset          = 3.0
            label  
          end

          @yaxis.axisLabels = NSSet.setWithArray(labels)  
        end

        @yaxis.setLabelTextStyle(axis.text_style)
      end

      @graph.axisSet = nil if(not @axes[:x].enabled? and not @axes[:y].enabled?)

      add_series

      add_legend if(@legend.enabled?)

      add_xy_range

      @layer_hosting_view
    end

    def add_plot_space
      @plot_space                       = @graph.defaultPlotSpace
      @plot_space.delegate              = self
      @plot_space.allowsUserInteraction = true
    end

    def add_plot_symbol(plot, symbol)
      plot.plotSymbol                       = symbol
      plot.plotSymbolMarginForHitDetection  = 5.0
    end

    def add_xy_range
      return if(not @axes[:x].enabled? and not @axes[:y].enabled?)
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
      @graph.legend               = @legend.cpt_legend(@graph)
      @graph.legendAnchor         = @legend.position
      @graph.legendDisplacement   = @legend.displacement
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

    protected
    def default_style
      # inheriting classes should implement this
      {}
    end
  end
end