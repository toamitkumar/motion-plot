class HomeViewController < UIViewController

  def viewDidLoad
    super
    @chart_view = UIView.alloc.initWithFrame([[10, 10], [800, 700]])
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
      curve_inerpolation: true,
      # orientation: "vertical",
      theme: MotionPlot::Theme.dark_gradient,
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
          font_size: 10
        }
      },
      plot_symbol: {
        enabled: true,
        size: 8
      },
      data_label: {
        color: "FFFFFF",
        font_size: 10,
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
          font_size: 10
        },
        enabled: true
      },
      legend: {
        enabled: false
      },
      series: [{
        name: 'Tokyo',
        data: [7.0, 6.9, 9.5, 14.5, 18.2, 21.5, 25.2, 26.5, 23.3, 18.3, 13.9, 9.6],
        color: "173B0B"
      }, {
        name: 'New York',
        data: [0.2, 0.8, 5.7, 11.3, 17.0, 22.0, 24.8, 24.1, 20.1, 14.1, 8.6, 2.5]
      }, {
        name: 'Berlin',
        data: [-0.9, 0.6, 3.5, 8.4, 13.5, 17.0, 18.6, 17.9, 14.3, 9.0, 3.9, 1.0]
      }, {
        name: 'London',
        data: [3.9, 4.2, 5.7, 8.5, 11.9, 15.2, 17.0, 16.6, 14.2, 10.3]
      }]
    }

    view = MotionPlot::Area.alloc.initWithOptions(options, containerView:@chart_view)
    @chart_view.addSubview(view)
  end

end