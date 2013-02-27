module MotionPlot
  class PlotOptions
    
    attr_accessor :options

    def initialize(args={})
      @options = {}
      args.each_pair{|k,v| @options[k] = v}
    end

    def method_missing(m, *args, &block)
      @options[m]
    end

  end
end