module MotionPlot
  class AnchorPosition
    class << self

      def top_right
        CPTRectAnchorTopRight
      end

      def bottom_left
        CPTRectAnchorBottomLeft
      end

      def bottom
        CPTRectAnchorBottom
      end

      def bottom_right
        CPTRectAnchorBottomRight
      end

      def left
        CPTRectAnchorLeft
      end

      def right
        CPTRectAnchorRight
      end

      def top_left
        CPTRectAnchorTopLeft
      end

      def default
        CPTRectAnchorTop
      end

      def top
        CPTRectAnchorTop
      end

      def center
        CPTRectAnchorCenter
      end

    end
  end
end