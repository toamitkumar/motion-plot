module MotionPlot
  class Series

    COLORS = ['4572A7', 'AA4643', '89A54E', '80699B', '3D96AE', 'DB843D', '92A8CD', 'A47D7C', 'B5CA92']

    attr_accessor :name, :data

    def initialize(args={})
      args.each_pair {|key, value|
        send("#{key}=", value) if(respond_to?("#{key}="))
      }

      defaults = {
        width: 2.0
      }

      style_attr = args[:style] || {}
      style_attr.merge!(color: COLORS[args[:index]]) if(style_attr.empty? or !(args[:style] and args[:style][:color]))

      @style = Style.new(defaults.merge(style_attr))
    end

    def color
      @style.color
    end

    def width
      @style.width
    end

  end
end