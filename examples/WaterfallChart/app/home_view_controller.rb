class HomeViewController < UIViewController

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
      plot_options: {
        bar: {
          stacking: 'waterfall',
          style: {
            width: 0.5
          }
        }
      },      
      series: [{
        name: 'Tokyo',
        data: [7.0, 6.9, 9.5, 14.5, 18.2, 21.5, 25.2, 26.5, 23.3, 18.3, 13.9, 9.6],
        style: {
          color: "0B73C8"
        }
      }]
    }

    view = MotionPlot::Bar.alloc.initWithOptions(options, containerView:@chart_view)
    @chart_view.addSubview(view)
  end

end