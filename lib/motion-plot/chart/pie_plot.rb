module MotionPlot
  class Pie < Base

    attr_accessor :selected_slice

    def add_series
      pie                 = CPTPieChart.alloc.init
      pie.dataSource      = self
      pie.delegate        = self
      pie.pieRadius       = pie_radius
      pie.startAngle      = Math::PI/4
      pie.sliceDirection  = CPTPieDirectionClockwise #CPTPieDirectionCounterClockwise
      pie.identifier      = plot_identifier
      
      series_data.each_with_index {|obj, i| @selected_slice = i if(obj[:selected]) }

      add_gradient(pie)

      animate(pie)
      @graph.addPlot(pie)
      @plots << pie
    end

    def default_padding
      pie_series.style.paddings_for(@graph)
      pie_series.style.plot_area.add_style(@graph.plotAreaFrame)
    end

    def numberOfRecordsForPlot(plot)
      series_data.size
    end

    def numberForPlot(plot, field: fieldEnum, recordIndex: index)
      fieldEnum == CPTPieChartFieldSliceWidth ? series_data[index][:y] : index
    end

    def legendTitleForPieChart(pie, recordIndex: index)
      series_data[index][:name]
    end    

    def sliceFillForPieChart(plot, recordIndex: index)
      CPTFill.alloc.initWithColor Series::COLORS[index].to_color.to_cpt_color
    end

    def radialOffsetForPieChart(plot, recordIndex: index)
      offset = 0.0

      if(@selected_slice == index)
        offset = pie_radius / 25.0
      end

      offset
    end

    def pieChart(plot, sliceWasSelectedAtRecordIndex: index)
      @selected_slice = index
      plot.reloadData
    end

    def dataLabelForPlot(plot, recordIndex: index)
      @data_label.annotation_text_style(series_data[index][:y].round(2))
    end

    protected
    def plot_type
      "pie"
    end

    def add_gradient(pie)
      if(pie_series.style.gradient)
        overlay_gradient              = CPTGradient.alloc.init
        overlay_gradient.gradientType = CPTGradientTypeRadial

        overlay_gradient              = overlay_gradient.addColorStop(CPTColor.blackColor.colorWithAlphaComponent(0.0), atPosition:0.0)
        overlay_gradient              = overlay_gradient.addColorStop(CPTColor.blackColor.colorWithAlphaComponent(0.3), atPosition:0.9)
        overlay_gradient              = overlay_gradient.addColorStop(CPTColor.blackColor.colorWithAlphaComponent(0.7), atPosition:1.0)
        pie.overlayFill               = overlay_gradient
      end
    end

    def pie_radius
      [
        0.8 * (@layer_hosting_view.frame.size.height - 2 * @graph.paddingLeft) / 2.0,
        0.8 * (@layer_hosting_view.frame.size.width - 2 * @graph.paddingTop) / 2.0
      ].min
    end

    def plot_identifier
      @series.keys.select{|k| @series[k].type == plot_type}.first
    end

    def series_data
      pie_series.data
    end

    def pie_series
      @series[plot_identifier]
    end

    def animate(plot)
      CATransaction.begin
      CATransaction.setAnimationDuration 2.0
      CATransaction.setAnimationTimingFunction CAMediaTimingFunction.functionWithName(KCAMediaTimingFunctionEaseIn)

      radial_animation                     = CABasicAnimation.animationWithKeyPath("pieRadius")

      radial_animation.fromValue           = 0.0
      radial_animation.toValue             = pie_radius
      radial_animation.duration            = 1.0
      radial_animation.removedOnCompletion = false
      radial_animation.fillMode            = KCAFillModeForwards

      plot.addAnimation(radial_animation, forKey:"pieRadius")


      angle_animation                     = CABasicAnimation.animationWithKeyPath 'endAngle'
      angle_animation.fromValue           = -(Math::PI * 7/4)
      angle_animation.toValue             = Math::PI/4
      angle_animation.duration            = 1.0
      angle_animation.removedOnCompletion = false
      angle_animation.fillMode            = KCAFillModeForwards

      plot.addAnimation(angle_animation, forKey:"endAngle")

      CATransaction.commit
    end

  end
end