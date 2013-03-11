module MotionPlot
  class PlotArea

    attr_accessor :padding, :mask_to_border, :border_line_style, :corner_radius

    def self.default_border_line_style
      line_style = CPTMutableLineStyle.lineStyle
      line_style.lineColor = CPTColor.blackColor
      line_style.lineWidth = 2.0

      line_style
    end

    DEFAULTS = {
      padding: [50.0, 10.0, 20.0, 20.0],
      border_line_style: default_border_line_style,
      mask_to_border: false,
      corner_radius: 5.0
    }

    def initialize(args={})
      options = DEFAULTS.merge(args)

      options.each_pair {|key, value|
        send("#{key}=", value) if(respond_to?("#{key}="))
      }
    end

    def add_style(graph_plot_area)
      graph_plot_area.masksToBorder     = @mask_to_border
      graph_plot_area.borderLineStyle   = @border_line_style || nil
      graph_plot_area.cornerRadius      = @corner_radius unless(border_line_style.nil?)


      %W(left top right bottom).each_with_index do |pos, index|
        graph_plot_area.send("padding#{pos.camelize}=", @padding[index]) unless(padding[index].nil?)
      end

      graph_plot_area
    end

  end
end