module MotionPlot
  class Theme
    DEFAULTS = {
      :dark_gradient  => KCPTDarkGradientTheme,
      :plain_black    => KCPTPlainBlackTheme,
      :plain_white    => KCPTPlainWhiteTheme,
      :slate          => KCPTSlateTheme,
      :stocks         => KCPTStocksTheme
    }

    class << self
      def method_missing(m, *args, &block)
        raise unless(DEFAULTS.keys.include?(m))       

        CPTTheme.themeNamed(DEFAULTS[m])
      end
    end

  end
end