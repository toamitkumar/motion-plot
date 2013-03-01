module MotionPlot
  class Series

    COLORS = ['4572A7', 'AA4643', '89A54E', '80699B', '3D96AE', 'DB843D', '92A8CD', 'A47D7C', 'B5CA92']

    attr_accessor :name, :data, :index, :type, :style

    def initialize(args={})
      args.each_pair {|key, value|
        send("#{key}=", value) if(respond_to?("#{key}="))
      }

      style_attr = args[:defaults].merge!(color: COLORS[args[:index]])
      merge_plot_options(style_attr, args[:plot_options])
      merge_style(style_attr, args[:style])

      @style = Style.new(style_attr)
    end

    def color
      @style.color
    end

    def width
      @style.width
    end

    private
    def merge_plot_options(style, plot_options)
      return if(plot_options.nil?)
      return if(plot_options.send(type).nil?)
      return if(plot_options.send(type)[:style].nil?)

      merge_style(style, plot_options.send(type)[:style])
    end

    def merge_style(old_style, new_style)
      old_style.merge!(new_style) {|key, old_val, new_val| 
        new_val.nil? ? old_val : new_val
      } if(new_style)
    end    

  end
end