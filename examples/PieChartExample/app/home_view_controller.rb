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
        color: '0000FF',
        font_name: "Arial"
      },
      theme: MotionPlot::Theme.plain_white,
      data_label: {
        color: "0000FF",
        font_size: 8,
        font_name: "Arial",
        displacement: [0, 10]
      },
      legend: {
        enabled: true
      },
      series: [{
        name: 'Browser Share',
        data: [
          {
            name: 'Firefox',
            y: 30.2,
            style: {
              color: "173B0B"
            }
          }, 
          {
            name: "Chrome",
            y: 48.4
          },
          {
            name: "Safari",
            y: 4.2
          },
          {
            name: "Opera",
            y: 1.9
          },
          {
            name: "IE",
            y: 14.3
          }
        ]
      }]
    }

    view = MotionPlot::Pie.alloc.initWithOptions(options, containerView:@chart_view)
    @chart_view.addSubview(view)
  end

end