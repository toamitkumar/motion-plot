class HomeViewController < UIViewController

  def viewDidLoad
    super
    @chart_view = UIView.alloc.initWithFrame([[10, 10], [700, 500]])
    @chart_view.backgroundColor = UIColor.whiteColor

    add_chart

    self.view.addSubview(@chart_view)
  end

  def add_chart

    options = {
      title: {
        text: "Browser Market Share 2013 - W3C",
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
        enabled: true,
        style: {

        },
        swatch_size: [25.0, 25.0],
        position: "top_right",
        displacement: [0.0, 0.0],
        fill_color: "173B0B",
        radius: 4.0,
        number_of_rows: 1,
        number_of_columns: 2
      },
      plot_options: {
        pie: {
          style: {
            gradient: true
          }
        }
      },
      series: [{
        name: 'Browser Share',
        data: [
          {
            name: 'Firefox',
            y: 30.2,
            selected: true,
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