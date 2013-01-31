class AppDelegate
  
  def application(application, didFinishLaunchingWithOptions:launchOptions)

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

    @chart_view = GraphHostingView.alloc.initWithFrame [[10, 10], [App.frame.size.width-10, App.frame.size.height]]

    

    true
  end
  
end