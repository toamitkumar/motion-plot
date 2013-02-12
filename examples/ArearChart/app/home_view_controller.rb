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
        color: '0000FF',
        font_name: "Arial"
      },
      curve_inerpolation: true,
      # orientation: "vertical",
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
        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
        style: {
          color: "0000FF",
          font_name: "Arial",
          font_size: 8
        }
      },
      plot_symbol: {
        enabled: true,
        size: 8
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
        style: {
          color: "0000FF",
          font_name: "Arial",
          font_size: 8
        },
        enabled: true
      },
      legend: {
        enabled: false
      },
      series: [{
        name: 'Tokyo',
        data: [
          [7.0, 'Jan'], 
          [6.9, 'Feb'], 
          [9.5, 'Mar'], 
          [14.5, 'Apr'], 
          [18.2, 'May'], 
          [21.5, 'Jun'], 
          [25.2, 'Jul'], 
          [26.5, 'Aug'], 
          [23.3, 'Sep'], 
          [18.3, 'Oct'], 
          [13.9, 'Nov'], 
          [9.6, 'Dec']
        ],
        color: "173B0B"
      }, {
        name: 'New York',
        data: [
          [-0.2, 'Jan'], 
          [0.8, 'Feb'], 
          [5.7, 'Mar'], 
          [11.3, 'Apr'], 
          [17.0, 'May'], 
          [22.0, 'Jun'], 
          [24.8, 'Jul'], 
          [24.1, 'Aug'], 
          [20.1, 'Sep'], 
          [14.1, 'Oct'], 
          [8.6, 'Nov'], 
          [2.5, 'Dec']
        ]
      }, {
        name: 'Berlin',
        data: [[-0.9, 'Jan'], [0.6, 'Feb'], [3.5, 'Mar'], [8.4, 'Apr'], [13.5, 'May'], [17.0, 'Jun'], [18.6, 'Jul'], [17.9, 'Aug'], [14.3, 'Sep'], [9.0, 'Oct'], [3.9, 'Nov'], [1.0, 'Dec']]
      }, {
        name: 'London',
        data: [[3.9, 'Jan'], [4.2, 'Feb'], [5.7, 'Mar'], [8.5, 'Apr'], [11.9, 'May'], [15.2, 'Jun'], [17.0, 'Jul'], [16.6, 'Aug'], [14.2, 'Sep'], [-10.3, 'Oct'], [0.1, 'Nov']]
      }]
    }

    view = MotionPlot::Area.alloc.initWithOptions(options, containerView:@chart_view)
    @chart_view.addSubview(view)
  end

end