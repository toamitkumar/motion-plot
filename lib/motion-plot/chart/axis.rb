module MotionPlot
  class Axis
    attr_accessor :title, :enabled, :color, :type, :labels

    def initialize(args)
      args.each_pair {|key, value|
        send("#{key}=", value) if(respond_to?("#{key}="))
      }
    end


    def is_x?
      type == "xaxis"
    end

    def is_y?
      type == "yaxis"
    end
  end
end