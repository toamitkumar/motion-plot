module MotionPlot
  class Legend

    attr_accessor :swatch_size, :corner_radius, :number_of_columns, :number_of_rows, :position, :displacement, :enabled, :style, :fill_color

    DEFAULTS = {
      swatch_size: [25.0, 25.0],
      corner_radius: 5,
      position: "top",
      displacement: [0.0, 0.0],
      fill_color: "FFFFFF"
    }

    def initialize(args={})
      options = DEFAULTS.merge(args)

      options.each_pair {|key, value|
        send("#{key}=", value) if(respond_to?("#{key}="))
      }

      if(style)
        @style = Style.new(args[:style])
      end
    end

    def enabled?
      enabled
    end

    def position
      AnchorPosition.send(@position)
    end

    def cpt_legend(graph)
      legend              = CPTLegend.legendWithGraph(graph)
      legend.fill         = CPTFill.fillWithColor(fill_color.to_color.to_cpt_color)
      legend.cornerRadius = corner_radius
      legend.swatchSize   = swatch_size
      legend
    end

  end
end