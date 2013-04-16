class InteractiveChartViewController < UIViewController
  def init
    if super
      self.tabBarItem = UITabBarItem.alloc.initWithTitle('Interactive', image:UIImage.imageNamed('interactive_chart.png'), tag:1)
    end
    self
  end


  def viewDidLoad
    super
    @chart_view = UIView.alloc.initWithFrame([[10, 10], [900, 700]])
    @chart_view.backgroundColor = UIColor.whiteColor

    add_chart

    self.view.addSubview(@chart_view)
  end

  def add_chart

    options = {
      title: {
        text: "Monthly Average Temperature",
        color: '0000FF',
        font_name: "Arial"
      },
      theme: MotionPlot::Theme.dark_gradient,
      xAxis: {
        title: {
          text: 'Months - 2013',
          color: "0000FF",
          font_name: "Arial",
          offset: 30.0
        },
        enabled: true,
        color: '808080',
      },
      data_label: {
        color: "0000FF",
        font_size: 8,
        font_name: "Arial",
        displacement: [0, 10]
      },
      yAxis: {
        title: {
          text: 'Temperature (°C)',
          color: "0000FF",
          font_name: "Arial",
          offset: 30.0
        },
        enabled: true
      },
      legend: {
        enabled: false
      },
      plot_options: {
        line: {
          data_size: 100,
          beizer: true,
          curve_inerpolation: true,
          step_size: 1
        }
      },
      series: [{
        name: 'Tokyo',
        data: lambda{|p| 0.5 * p * p}
      }, {
        name: 'New York',
        data: lambda{|p| 2.0 * p * p}
      }, {
        name: 'Berlin',
        data: lambda{|p| 4.0 * p * p}
      }, {
        name: 'London',
        data: lambda{|p| 8.0 * p * p}
      }, {
        name: "Static_1",
        data: lambda{|p| 4.0 * 5 * 5},
        plot_symbol: {
          type: 'pentagon',
          size: 8
        }
      # }, {
      #   name: "Static_2",
      #   data: [4]
      }]
    }

    view = MotionPlot::Line.alloc.initWithOptions(options, containerView:@chart_view)
    @chart_view.addSubview(view)

  end

end
