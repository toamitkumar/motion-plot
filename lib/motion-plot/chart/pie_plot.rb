module MotionPlot
  class Pie < Base

    def add_series
      pie                 = CPTPieChart.alloc.init
      pie.dataSource      = self
      pie.delegate        = self
      pie.pieRadius       = pie_radius
      pie.startAngle      = Math::PI/2
      pie.sliceDirection  = CPTPieDirectionCounterClockwise #CPTPieDirectionCounterClockwise

      animate(pie)
      @graph.addPlot(pie)
    end

    def numberOfRecordsForPlot(plot)
      series_data.size
    end

    def numberForPlot(plot, field: fieldEnum, recordIndex: index)
      fieldEnum == CPTPieChartFieldSliceWidth ? series_data[index][:y] : index
    end

    def sliceFillForPieChart(plot, recordIndex: index)
      CPTFill.alloc.initWithColor Series::COLORS[index].to_color.to_cpt_color
    end

    protected
    def plot_type
      "pie"
    end

    def pie_radius
      [
        0.9 * (@layer_hosting_view.frame.size.height - 2 * @graph.paddingLeft) / 2.0,
        0.9 * (@layer_hosting_view.frame.size.width - 2 * @graph.paddingTop) / 2.0
      ].min
    end

    def series_data
      key = @series.keys.select{|k| @series[k].type == plot_type}.first
      @series[key].data
    end

    def animate(plot)
      CATransaction.begin
      radial_animation                     = CABasicAnimation.animationWithKeyPath("pieRadius")

      radial_animation.fromValue           = 0.0
      radial_animation.toValue             = pie_radius
      radial_animation.duration            = 1.0
      radial_animation.removedOnCompletion = false
      radial_animation.fillMode            = KCAFillModeForwards

      plot.addAnimation(radial_animation, forKey:"pieRadius")


      angle_animation  = CABasicAnimation.animationWithKeyPath 'angle'
      angle_animation.fromValue           = 0.0
      angle_animation.toValue             = Math::PI/2
      angle_animation.duration            = 1.0
      angle_animation.removedOnCompletion = false
      angle_animation.fillMode            = KCAFillModeForwards

      plot.addAnimation(angle_animation, forKey:"angle") 

      CATransaction.commit     

      # CATransaction.begin

      # CATransaction.setAnimationDuration 2.0
      # CATransaction.setAnimationTimingFunction CAMediaTimingFunction.functionWithName(KCAMediaTimingFunctionEaseIn)

      # animation = CABasicAnimation.animationWithKeyPath "pieRadius"
      # animation.fromValue           = NSNumber.numberWithDouble 0
      # animation.toValue             = NSNumber.numberWithDouble radius
      # animation.fillMode            = KCAFillModeForwards
      # plot.addAnimation animation, forKey: "pieRadius"

      # animation          = CABasicAnimation.animationWithKeyPath 'startAngle'
      # animation.fromValue           = NSNumber.numberWithDouble 0
      # animation.toValue             = NSNumber.numberWithDouble Math::PI/2
      # animation.fillMode            = KCAFillModeForwards
      # plot.addAnimation animation, forKey: "startAngle"

      # CATransaction.commit
    end

  end
end