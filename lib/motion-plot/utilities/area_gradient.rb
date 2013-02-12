module MotionPlot
  class AreaGradient

    attr_accessor :angle

    def initialize(orientation)
      @angle = (orientation == "vertical") ? 0.0 : -90.0
    end

    def fill_with(color)
      gradient        = CPTGradient.gradientWithBeginningColor(color, endingColor:CPTColor.clearColor)
      gradient.angle  = @angle
      
      CPTFill.fillWithGradient(gradient)
    end

  end
end