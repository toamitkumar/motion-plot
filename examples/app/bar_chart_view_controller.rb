class BarChartViewController < UIViewController
  def init
    if super
      self.tabBarItem = UITabBarItem.alloc.initWithTitle('Bar', image:UIImage.imageNamed('bar_chart.png'), tag:1)
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
        color: 'FFFFFF',
        font_name: "Arial"
      },
      theme: MotionPlot::Theme.plain_white,
      xAxis: {
        title: {
          text: 'Months - 2013',
          color: "FFFFFF",
          font_name: "Arial",
          offset: 30.0
        },
        enabled: true,
        color: '808080',
        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
        style: {
          color: "FFFFFF",
          font_name: "Arial",
          font_size: 12
        }
      },
      data_label: {
        color: "000000",
        font_size: 12,
        font_name: "Arial",
        displacement: [0, 10]
      },
      yAxis: {
        title: {
          text: 'Temperature (°C)',
          color: "FFFFFF",
          font_name: "Arial",
          offset: 30.0
        },
        style: {
          color: "FFFFFF",
          font_name: "Arial",
          font_size: 12
        },
        enabled: true
      },
      legend: {
        enabled: true
      },
      series: [{
        name: 'Tokyo',
        data: [7.0, 6.9, 9.5, 14.5, 18.2, 21.5, 25.2, 26.5, 23.3, 18.3, 13.9, 9.6],
        style: {
          color: "173B0B",
          width: 0.25
        }
      }, {
        name: 'New York',
        data: [0.2, -0.8, 5.7, 11.3, 17.0, 22.0, 24.8, 24.1, 20.1, 14.1, 8.6, 2.5]
      }]
    }

    view = MotionPlot::Bar.alloc.initWithOptions(options, containerView:@chart_view)
    @chart_view.addSubview(view)
  end

end
