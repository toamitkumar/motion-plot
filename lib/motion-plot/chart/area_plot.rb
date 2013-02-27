module MotionPlot
  class Area < Line

    def plot_type
      "area"
    end

    def add_series
      super
      @plots.each do |line|
        add_area_gradient(line)
      end
    end

    def add_area_gradient(line)
      line.areaFill       = AreaGradient.new(@orientation).fill_with(line.dataLineStyle.lineColor)
      line.areaBaseValue  = CPTDecimalFromString("0.0")
    end    

    protected
    
    def plot_type
      "area"
    end

  end
end