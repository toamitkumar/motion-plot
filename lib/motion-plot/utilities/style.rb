module MotionPlot
  class Style
    attr_accessor :font_name, :font_size, :offset, :alignment, :color, :rotation, :width, :gradient, :padding, :plot_area

    DEFAULTS = {
      font_name: "Helvetica",
      font_size: 10,
      offset: 10,
      color: "000000",
      padding: [5.0, 10.0, 5.0, 10.0]
    }

    def initialize(args={})
      options = DEFAULTS.merge(args)

      options.each_pair {|key, value|
        send("#{key}=", value) if(respond_to?("#{key}="))
      }

      @plot_area = PlotArea.new(args[:plot_area] || {})
    end

    def paddings_for(graph)
      %W(left top right bottom).each_with_index do |pos, index|
        graph.send("padding#{pos.camelize}=", @padding[index]) unless(padding[index].nil?)
      end
    end

    def color
      @color.to_color.to_cpt_color
    end

  end
end