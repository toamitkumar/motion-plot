class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = UITabBarController.alloc.init
    @window.rootViewController.wantsFullScreenLayout = true

    chart_view_controllers = [
      AreaChartViewController,
      LineChartViewController,
      BarChartViewController,
      StackedBarChartViewController,
      PercentStackedBarChartViewController,
      VerticalBarChartViewController,
      PieChartViewController,
      WaterfallChartViewController,
      # InteractiveChartViewController,
    ]
    chart_view_controller_instances = chart_view_controllers.map do |chart_view_controller|
      chart_view_controller.alloc.init
    end
    @window.rootViewController.viewControllers = chart_view_controller_instances

    @window.makeKeyAndVisible
    true
  end
end
