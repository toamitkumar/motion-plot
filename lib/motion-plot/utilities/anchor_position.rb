module MotionPlot
  class AnchorPosition
    DEFAULTS = {
      :top_right      => CPTRectAnchorTopRight,
      :bottom_left    => CPTRectAnchorBottomLeft,
      :bottom         => CPTRectAnchorBottom,
      :bottom_right   => CPTRectAnchorBottomRight,
      :left           => CPTRectAnchorLeft,
      :right          => CPTRectAnchorRight,
      :top_left       => CPTRectAnchorTopLeft,
      :top            => CPTRectAnchorTop,
      :center         => CPTRectAnchorCenter 
    }

    class << self

      def method_missing(m, *args, &block)
        method_name = m == :default ? :top : m

        raise unless(DEFAULTS.keys.include?(method_name))        

        DEFAULTS[method_name]
      end      

    end
  end
end