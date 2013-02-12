module MotionPlot
  class Area < Line

    def add_series

    end

    def initWithOptions(options, containerView:container)
      super

      @plots.each do |line|
        add_area_gradient(line)
      end      

      @layer_hosting_view
    end

    def add_area_gradient(line)
      area_color          = line.dataLineStyle.lineColor
      area_gradient       = CPTGradient.gradientWithBeginningColor(area_color, endingColor:CPTColor.clearColor)
      area_gradient.angle = -90.0
      area_gradient_fill  = CPTFill.fillWithGradient(area_gradient)

      line.areaFill       = area_gradient_fill
      line.areaBaseValue  = CPTDecimalFromString("0.0")
    end
  end
end