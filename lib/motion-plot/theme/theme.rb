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
        method_name = m == :default ? :plain_white : m

        raise unless(DEFAULTS.keys.include?(method_name))       

        CPTTheme.themeNamed(DEFAULTS[method_name])
      end
    end

  end
end