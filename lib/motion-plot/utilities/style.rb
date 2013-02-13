module MotionPlot
  class Style
    attr_accessor :font_name, :font_size, :offset, :alignment, :color, :rotation

    DEFAULTS = {
      font_name: "Helvetica",
      font_size: 10,
      offset: 10,
      color: "000000"
    }

    def initialize(args={})
      options = DEFAULTS.merge(args)

      options.each_pair {|key, value|
        send("#{key}=", value) if(respond_to?("#{key}="))
      }
    end

    def color
      @color.to_color.to_cpt_color
    end

  end
end