#import "CPTPathExtensions.h"

/** @brief Creates a rectangular path with rounded corners.
 *
 *  @param rect The bounding rectangle for the path.
 *  @param cornerRadius The radius of the rounded corners.
 *  @return The new path. Caller is responsible for releasing this.
 **/
CGPathRef CreateRoundedRectPath(CGRect rect, CGFloat cornerRadius)
{
    // In order to draw a rounded rectangle, we will take advantage of the fact that
    // CGPathAddArcToPoint will draw straight lines past the start and end of the arc
    // in order to create the path from the current position and the destination position.

    CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);

    CGMutablePathRef path = CGPathCreateMutable();

    CGPathMoveToPoint(path, NULL, minx, midy);
    CGPathAddArcToPoint(path, NULL, minx, miny, midx, miny, cornerRadius);
    CGPathAddArcToPoint(path, NULL, maxx, miny, maxx, midy, cornerRadius);
    CGPathAddArcToPoint(path, NULL, maxx, maxy, midx, maxy, cornerRadius);
    CGPathAddArcToPoint(path, NULL, minx, maxy, minx, midy, cornerRadius);
    CGPathCloseSubpath(path);

    return path;
}

/** @brief Adds a rectangular path with rounded corners to a graphics context.
 *
 *  @param context The graphics context.
 *  @param rect The bounding rectangle for the path.
 *  @param cornerRadius The radius of the rounded corners.
 **/
void AddRoundedRectPath(CGContextRef context, CGRect rect, CGFloat cornerRadius)
{
    CGPathRef path = CreateRoundedRectPath(rect, cornerRadius);

    CGContextAddPath(context, path);
    CGPathRelease(path);
}
