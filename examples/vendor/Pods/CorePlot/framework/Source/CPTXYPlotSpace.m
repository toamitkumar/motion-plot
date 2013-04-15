#import "CPTXYPlotSpace.h"

#import "CPTAxisSet.h"
#import "CPTExceptions.h"
#import "CPTGraph.h"
#import "CPTGraphHostingView.h"
#import "CPTMutablePlotRange.h"
#import "CPTPlot.h"
#import "CPTPlotArea.h"
#import "CPTPlotArea.h"
#import "CPTPlotAreaFrame.h"
#import "CPTUtilities.h"
#import "CPTXYAxis.h"
#import "CPTXYAxisSet.h"
#import "NSNumberExtensions.h"

/// @cond
@interface CPTXYPlotSpace()

-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPTPlotRange *)range plotCoordinateValue:(NSDecimal)plotCoord;
-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPTPlotRange *)range doublePrecisionPlotCoordinateValue:(double)plotCoord;

-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength logPlotRange:(CPTPlotRange *)range doublePrecisionPlotCoordinateValue:(double)plotCoord;

-(NSDecimal)plotCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPTPlotRange *)range boundsLength:(CGFloat)boundsLength;
-(double)doublePrecisionPlotCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPTPlotRange *)range boundsLength:(CGFloat)boundsLength;

-(double)doublePrecisionPlotCoordinateForViewLength:(CGFloat)viewLength logPlotRange:(CPTPlotRange *)range boundsLength:(CGFloat)boundsLength;

-(CPTPlotRange *)constrainRange:(CPTPlotRange *)existingRange toGlobalRange:(CPTPlotRange *)globalRange;

@end

/// @endcond

#pragma mark -

/**
 *  @brief A plot space using a two-dimensional cartesian coordinate system.
 *
 *  The @ref xRange and @ref yRange determine the mapping between data coordinates
 *  and the screen coordinates in the plot area. The @quote{end} of a range is
 *  the location plus its length. Note that the length of a plot range can be negative, so
 *  the end point can have a lesser value than the starting location.
 *
 *  The global ranges constrain the values of the @ref xRange and @ref yRange.
 *  Whenever the global range is set (non-@nil), the corresponding plot
 *  range will be adjusted so that it fits in the global range. When a new
 *  range is set to the plot range, it will be adjusted as needed to fit
 *  in the global range. This is useful for constraining scrolling, for
 *  instance.
 **/
@implementation CPTXYPlotSpace

/** @property CPTPlotRange *xRange
 *  @brief The range of the x coordinate. Defaults to a range with @link CPTPlotRange::location location @endlink zero (@num{0})
 *  and a @link CPTPlotRange::length length @endlink of one (@num{1}).
 *
 *  The @link CPTPlotRange::location location @endlink of the @ref xRange
 *  defines the data coordinate associated with the left edge of the plot area.
 *  Similarly, the @link CPTPlotRange::end end @endlink of the @ref xRange
 *  defines the data coordinate associated with the right edge of the plot area.
 **/
@synthesize xRange;

/** @property CPTPlotRange *yRange
 *  @brief The range of the y coordinate. Defaults to a range with @link CPTPlotRange::location location @endlink zero (@num{0})
 *  and a @link CPTPlotRange::length length @endlink of one (@num{1}).
 *
 *  The @link CPTPlotRange::location location @endlink of the @ref yRange
 *  defines the data coordinate associated with the bottom edge of the plot area.
 *  Similarly, the @link CPTPlotRange::end end @endlink of the @ref yRange
 *  defines the data coordinate associated with the top edge of the plot area.
 **/
@synthesize yRange;

/** @property CPTPlotRange *globalXRange
 *  @brief The global range of the x coordinate to which the @ref xRange is constrained.
 *
 *  If non-@nil, the @ref xRange and any changes to it will
 *  be adjusted so that it always fits within the @ref globalXRange.
 *  If @nil (the default), there is no constraint on x.
 **/
@synthesize globalXRange;

/** @property CPTPlotRange *globalYRange
 *  @brief The global range of the y coordinate to which the @ref yRange is constrained.
 *
 *  If non-@nil, the @ref yRange and any changes to it will
 *  be adjusted so that it always fits within the @ref globalYRange.
 *  If @nil (the default), there is no constraint on y.
 **/
@synthesize globalYRange;

/** @property CPTScaleType xScaleType
 *  @brief The scale type of the x coordinate. Defaults to #CPTScaleTypeLinear.
 **/
@synthesize xScaleType;

/** @property CPTScaleType yScaleType
 *  @brief The scale type of the y coordinate. Defaults to #CPTScaleTypeLinear.
 **/
@synthesize yScaleType;

#pragma mark -
#pragma mark Init/Dealloc

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTXYPlotSpace object.
 *
 *  The initialized object will have the following properties:
 *  - @ref xRange = [@num{0}, @num{1}]
 *  - @ref yRange = [@num{0}, @num{1}]
 *  - @ref globalXRange = @nil
 *  - @ref globalYRange = @nil
 *  - @ref xScaleType = #CPTScaleTypeLinear
 *  - @ref yScaleType = #CPTScaleTypeLinear
 *
 *  @return The initialized object.
 **/
-(id)init
{
    if ( (self = [super init]) ) {
        xRange        = [[CPTPlotRange alloc] initWithLocation:CPTDecimalFromInteger(0) length:CPTDecimalFromInteger(1)];
        yRange        = [[CPTPlotRange alloc] initWithLocation:CPTDecimalFromInteger(0) length:CPTDecimalFromInteger(1)];
        globalXRange  = nil;
        globalYRange  = nil;
        xScaleType    = CPTScaleTypeLinear;
        yScaleType    = CPTScaleTypeLinear;
        lastDragPoint = CGPointZero;
        isDragging    = NO;
    }
    return self;
}

/// @}

/// @cond

-(void)dealloc
{
    [xRange release];
    [yRange release];
    [globalXRange release];
    [globalYRange release];
    [super dealloc];
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];

    [coder encodeObject:self.xRange forKey:@"CPTXYPlotSpace.xRange"];
    [coder encodeObject:self.yRange forKey:@"CPTXYPlotSpace.yRange"];
    [coder encodeObject:self.globalXRange forKey:@"CPTXYPlotSpace.globalXRange"];
    [coder encodeObject:self.globalYRange forKey:@"CPTXYPlotSpace.globalYRange"];
    [coder encodeInt:self.xScaleType forKey:@"CPTXYPlotSpace.xScaleType"];
    [coder encodeInt:self.yScaleType forKey:@"CPTXYPlotSpace.yScaleType"];

    // No need to archive these properties:
    // lastDragPoint
    // isDragging
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
        xRange       = [[coder decodeObjectForKey:@"CPTXYPlotSpace.xRange"] copy];
        yRange       = [[coder decodeObjectForKey:@"CPTXYPlotSpace.yRange"] copy];
        globalXRange = [[coder decodeObjectForKey:@"CPTXYPlotSpace.globalXRange"] copy];
        globalYRange = [[coder decodeObjectForKey:@"CPTXYPlotSpace.globalYRange"] copy];
        xScaleType   = (CPTScaleType)[coder decodeIntForKey : @"CPTXYPlotSpace.xScaleType"];
        yScaleType   = (CPTScaleType)[coder decodeIntForKey : @"CPTXYPlotSpace.yScaleType"];

        lastDragPoint = CGPointZero;
        isDragging    = NO;
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark Ranges

/// @cond

-(void)setPlotRange:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
    switch ( coordinate ) {
        case CPTCoordinateX:
            self.xRange = newRange;
            break;

        case CPTCoordinateY:
            self.yRange = newRange;
            break;

        default:
            // invalid coordinate--do nothing
            break;
    }
}

-(CPTPlotRange *)plotRangeForCoordinate:(CPTCoordinate)coordinate
{
    CPTPlotRange *theRange = nil;

    switch ( coordinate ) {
        case CPTCoordinateX:
            theRange = self.xRange;
            break;

        case CPTCoordinateY:
            theRange = self.yRange;
            break;

        default:
            // invalid coordinate
            break;
    }

    return theRange;
}

-(void)setScaleType:(CPTScaleType)newType forCoordinate:(CPTCoordinate)coordinate
{
    switch ( coordinate ) {
        case CPTCoordinateX:
            self.xScaleType = newType;
            break;

        case CPTCoordinateY:
            self.yScaleType = newType;
            break;

        default:
            // invalid coordinate--do nothing
            break;
    }
}

-(CPTScaleType)scaleTypeForCoordinate:(CPTCoordinate)coordinate
{
    CPTScaleType theScaleType = CPTScaleTypeLinear;

    switch ( coordinate ) {
        case CPTCoordinateX:
            theScaleType = self.xScaleType;
            break;

        case CPTCoordinateY:
            theScaleType = self.yScaleType;
            break;

        default:
            // invalid coordinate
            break;
    }

    return theScaleType;
}

-(void)setXRange:(CPTPlotRange *)range
{
    NSParameterAssert(range);

    if ( ![range isEqualToRange:xRange] ) {
        CPTPlotRange *constrainedRange = [self constrainRange:range toGlobalRange:self.globalXRange];
        [xRange release];
        xRange = [constrainedRange copy];

        [[NSNotificationCenter defaultCenter] postNotificationName:CPTPlotSpaceCoordinateMappingDidChangeNotification
                                                            object:self];

        id<CPTPlotSpaceDelegate> theDelegate = self.delegate;
        if ( [theDelegate respondsToSelector:@selector(plotSpace:didChangePlotRangeForCoordinate:)] ) {
            [theDelegate plotSpace:self didChangePlotRangeForCoordinate:CPTCoordinateX];
        }

        CPTGraph *theGraph = self.graph;
        if ( theGraph ) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CPTGraphNeedsRedrawNotification
                                                                object:theGraph];
        }
    }
}

-(void)setYRange:(CPTPlotRange *)range
{
    NSParameterAssert(range);

    if ( ![range isEqualToRange:yRange] ) {
        CPTPlotRange *constrainedRange = [self constrainRange:range toGlobalRange:self.globalYRange];
        [yRange release];
        yRange = [constrainedRange copy];

        [[NSNotificationCenter defaultCenter] postNotificationName:CPTPlotSpaceCoordinateMappingDidChangeNotification
                                                            object:self];

        id<CPTPlotSpaceDelegate> theDelegate = self.delegate;
        if ( [theDelegate respondsToSelector:@selector(plotSpace:didChangePlotRangeForCoordinate:)] ) {
            [theDelegate plotSpace:self didChangePlotRangeForCoordinate:CPTCoordinateY];
        }

        CPTGraph *theGraph = self.graph;
        if ( theGraph ) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CPTGraphNeedsRedrawNotification
                                                                object:theGraph];
        }
    }
}

-(CPTPlotRange *)constrainRange:(CPTPlotRange *)existingRange toGlobalRange:(CPTPlotRange *)globalRange
{
    if ( !globalRange ) {
        return existingRange;
    }
    if ( !existingRange ) {
        return nil;
    }

    if ( CPTDecimalGreaterThanOrEqualTo(existingRange.length, globalRange.length) ) {
        return [[globalRange copy] autorelease];
    }
    else {
        CPTMutablePlotRange *newRange = [[existingRange mutableCopy] autorelease];
        [newRange shiftEndToFitInRange:globalRange];
        [newRange shiftLocationToFitInRange:globalRange];
        return newRange;
    }
}

-(void)setGlobalXRange:(CPTPlotRange *)newRange
{
    if ( ![newRange isEqualToRange:globalXRange] ) {
        [globalXRange release];
        globalXRange = [newRange copy];
        self.xRange  = [self constrainRange:self.xRange toGlobalRange:globalXRange];
    }
}

-(void)setGlobalYRange:(CPTPlotRange *)newRange
{
    if ( ![newRange isEqualToRange:globalYRange] ) {
        [globalYRange release];
        globalYRange = [newRange copy];
        self.yRange  = [self constrainRange:self.yRange toGlobalRange:globalYRange];
    }
}

-(void)scaleToFitPlots:(NSArray *)plots
{
    if ( plots.count == 0 ) {
        return;
    }

    // Determine union of ranges
    CPTMutablePlotRange *unionXRange = nil;
    CPTMutablePlotRange *unionYRange = nil;
    for ( CPTPlot *plot in plots ) {
        CPTPlotRange *currentXRange = [plot plotRangeForCoordinate:CPTCoordinateX];
        CPTPlotRange *currentYRange = [plot plotRangeForCoordinate:CPTCoordinateY];
        if ( !unionXRange ) {
            unionXRange = [currentXRange mutableCopy];
        }
        if ( !unionYRange ) {
            unionYRange = [currentYRange mutableCopy];
        }
        [unionXRange unionPlotRange:currentXRange];
        [unionYRange unionPlotRange:currentYRange];
    }

    // Set range
    NSDecimal zero = CPTDecimalFromInteger(0);
    if ( unionXRange && !CPTDecimalEquals(unionXRange.length, zero) ) {
        self.xRange = unionXRange;
    }
    if ( unionYRange && !CPTDecimalEquals(unionYRange.length, zero) ) {
        self.yRange = unionYRange;
    }

    [unionXRange release];
    [unionYRange release];
}

-(void)setXScaleType:(CPTScaleType)newScaleType
{
    if ( newScaleType != xScaleType ) {
        xScaleType = newScaleType;

        [[NSNotificationCenter defaultCenter] postNotificationName:CPTPlotSpaceCoordinateMappingDidChangeNotification
                                                            object:self];

        CPTGraph *theGraph = self.graph;
        if ( theGraph ) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CPTGraphNeedsRedrawNotification
                                                                object:theGraph];
        }
    }
}

-(void)setYScaleType:(CPTScaleType)newScaleType
{
    if ( newScaleType != yScaleType ) {
        yScaleType = newScaleType;

        [[NSNotificationCenter defaultCenter] postNotificationName:CPTPlotSpaceCoordinateMappingDidChangeNotification
                                                            object:self];
        CPTGraph *theGraph = self.graph;
        if ( theGraph ) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CPTGraphNeedsRedrawNotification
                                                                object:theGraph];
        }
    }
}

/// @endcond

#pragma mark -
#pragma mark Point Conversion (private utilities)

/// @cond

// Linear
-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPTPlotRange *)range plotCoordinateValue:(NSDecimal)plotCoord
{
    if ( !range ) {
        return CPTFloat(0.0);
    }

    NSDecimal factor = CPTDecimalDivide(CPTDecimalSubtract(plotCoord, range.location), range.length);
    if ( NSDecimalIsNotANumber(&factor) ) {
        factor = CPTDecimalFromInteger(0);
    }

    CGFloat viewCoordinate = viewLength * [[NSDecimalNumber decimalNumberWithDecimal:factor] cgFloatValue];

    return viewCoordinate;
}

-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPTPlotRange *)range doublePrecisionPlotCoordinateValue:(double)plotCoord
{
    if ( !range || (range.lengthDouble == 0.0) ) {
        return CPTFloat(0.0);
    }
    return viewLength * (CGFloat)( (plotCoord - range.locationDouble) / range.lengthDouble );
}

-(NSDecimal)plotCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPTPlotRange *)range boundsLength:(CGFloat)boundsLength
{
    if ( boundsLength == 0.0 ) {
        return CPTDecimalFromInteger(0);
    }

    NSDecimal vLength = CPTDecimalFromDouble(viewLength);
    NSDecimal bLength = CPTDecimalFromDouble(boundsLength);

    NSDecimal location = range.location;
    NSDecimal length   = range.length;

    NSDecimal coordinate;
    NSDecimalDivide(&coordinate, &vLength, &bLength, NSRoundPlain);
    NSDecimalMultiply(&coordinate, &coordinate, &(length), NSRoundPlain);
    NSDecimalAdd(&coordinate, &coordinate, &(location), NSRoundPlain);

    return coordinate;
}

-(double)doublePrecisionPlotCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPTPlotRange *)range boundsLength:(CGFloat)boundsLength
{
    if ( boundsLength == 0.0 ) {
        return 0.0;
    }

    double coordinate = viewLength / boundsLength;
    coordinate *= range.lengthDouble;
    coordinate += range.locationDouble;

    return coordinate;
}

// Log (only one version since there are no trancendental functions for NSDecimal)
-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength logPlotRange:(CPTPlotRange *)range doublePrecisionPlotCoordinateValue:(double)plotCoord
{
    if ( (range.minLimitDouble <= 0.0) || (range.maxLimitDouble <= 0.0) || (plotCoord <= 0.0) ) {
        return CPTFloat(0.0);
    }

    double logLoc   = log10(range.locationDouble);
    double logCoord = log10(plotCoord);
    double logEnd   = log10(range.endDouble);

    return viewLength * (CGFloat)( (logCoord - logLoc) / (logEnd - logLoc) );
}

-(double)doublePrecisionPlotCoordinateForViewLength:(CGFloat)viewLength logPlotRange:(CPTPlotRange *)range boundsLength:(CGFloat)boundsLength
{
    if ( boundsLength == 0.0 ) {
        return 0.0;
    }

    double logLoc = log10(range.locationDouble);
    double logEnd = log10(range.endDouble);

    double coordinate = viewLength * (logEnd - logLoc) / boundsLength + logLoc;

    return pow(10.0, coordinate);
}

/// @endcond

#pragma mark -
#pragma mark Point Conversion

/// @cond

// Plot area view point for plot point
-(CGPoint)plotAreaViewPointForPlotPoint:(NSDecimal *)plotPoint
{
    CGSize layerSize      = CGSizeZero;
    CPTPlotArea *plotArea = self.graph.plotAreaFrame.plotArea;

    if ( plotArea ) {
        layerSize = plotArea.bounds.size;
    }
    else {
        return CGPointZero;
    }

    CGFloat viewX = CPTFloat(0.0);
    CGFloat viewY = CPTFloat(0.0);

    switch ( self.xScaleType ) {
        case CPTScaleTypeLinear:
            viewX = [self viewCoordinateForViewLength:layerSize.width linearPlotRange:self.xRange plotCoordinateValue:plotPoint[CPTCoordinateX]];
            break;

        case CPTScaleTypeLog:
        {
            double x = [[NSDecimalNumber decimalNumberWithDecimal:plotPoint[CPTCoordinateX]] doubleValue];
            viewX = [self viewCoordinateForViewLength:layerSize.width logPlotRange:self.xRange doublePrecisionPlotCoordinateValue:x];
        }
        break;

        default:
            [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
    }

    switch ( self.yScaleType ) {
        case CPTScaleTypeLinear:
            viewY = [self viewCoordinateForViewLength:layerSize.height linearPlotRange:self.yRange plotCoordinateValue:plotPoint[CPTCoordinateY]];
            break;

        case CPTScaleTypeLog:
        {
            double y = [[NSDecimalNumber decimalNumberWithDecimal:plotPoint[CPTCoordinateY]] doubleValue];
            viewY = [self viewCoordinateForViewLength:layerSize.height logPlotRange:self.yRange doublePrecisionPlotCoordinateValue:y];
        }
        break;

        default:
            [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
    }

    return CPTPointMake(viewX, viewY);
}

-(CGPoint)plotAreaViewPointForDoublePrecisionPlotPoint:(double *)plotPoint
{
    CGSize layerSize      = CGSizeZero;
    CPTPlotArea *plotArea = self.graph.plotAreaFrame.plotArea;

    if ( plotArea ) {
        layerSize = plotArea.bounds.size;
    }
    else {
        return CGPointZero;
    }

    CGFloat viewX = CPTFloat(0.0);
    CGFloat viewY = CPTFloat(0.0);

    switch ( self.xScaleType ) {
        case CPTScaleTypeLinear:
            viewX = [self viewCoordinateForViewLength:layerSize.width linearPlotRange:self.xRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateX]];
            break;

        case CPTScaleTypeLog:
            viewX = [self viewCoordinateForViewLength:layerSize.width logPlotRange:self.xRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateX]];
            break;

        default:
            [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
    }

    switch ( self.yScaleType ) {
        case CPTScaleTypeLinear:
            viewY = [self viewCoordinateForViewLength:layerSize.height linearPlotRange:self.yRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateY]];
            break;

        case CPTScaleTypeLog:
            viewY = [self viewCoordinateForViewLength:layerSize.height logPlotRange:self.yRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateY]];
            break;

        default:
            [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
    }

    return CPTPointMake(viewX, viewY);
}

// Plot point for view point
-(void)plotPoint:(NSDecimal *)plotPoint forPlotAreaViewPoint:(CGPoint)point
{
    CGSize boundsSize     = CGSizeZero;
    CPTPlotArea *plotArea = self.graph.plotAreaFrame.plotArea;

    if ( plotArea ) {
        boundsSize = plotArea.bounds.size;
    }
    else {
        NSDecimal zero = CPTDecimalFromInteger(0);
        plotPoint[CPTCoordinateX] = zero;
        plotPoint[CPTCoordinateY] = zero;
        return;
    }

    switch ( self.xScaleType ) {
        case CPTScaleTypeLinear:
            plotPoint[CPTCoordinateX] = [self plotCoordinateForViewLength:point.x linearPlotRange:self.xRange boundsLength:boundsSize.width];
            break;

        case CPTScaleTypeLog:
            plotPoint[CPTCoordinateX] = CPTDecimalFromDouble([self doublePrecisionPlotCoordinateForViewLength:point.x logPlotRange:self.xRange boundsLength:boundsSize.width]);
            break;

        default:
            [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
    }

    switch ( self.yScaleType ) {
        case CPTScaleTypeLinear:
            plotPoint[CPTCoordinateY] = [self plotCoordinateForViewLength:point.y linearPlotRange:self.yRange boundsLength:boundsSize.height];
            break;

        case CPTScaleTypeLog:
            plotPoint[CPTCoordinateY] = CPTDecimalFromDouble([self doublePrecisionPlotCoordinateForViewLength:point.y logPlotRange:self.yRange boundsLength:boundsSize.height]);
            break;

        default:
            [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
    }
}

-(void)doublePrecisionPlotPoint:(double *)plotPoint forPlotAreaViewPoint:(CGPoint)point
{
    CGSize boundsSize     = CGSizeZero;
    CPTPlotArea *plotArea = self.graph.plotAreaFrame.plotArea;

    if ( plotArea ) {
        boundsSize = plotArea.bounds.size;
    }
    else {
        plotPoint[CPTCoordinateX] = 0.0;
        plotPoint[CPTCoordinateY] = 0.0;
        return;
    }

    switch ( self.xScaleType ) {
        case CPTScaleTypeLinear:
            plotPoint[CPTCoordinateX] = [self doublePrecisionPlotCoordinateForViewLength:point.x linearPlotRange:self.xRange boundsLength:boundsSize.width];
            break;

        case CPTScaleTypeLog:
            plotPoint[CPTCoordinateX] = [self doublePrecisionPlotCoordinateForViewLength:point.x logPlotRange:self.xRange boundsLength:boundsSize.width];
            break;

        default:
            [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
    }

    switch ( self.yScaleType ) {
        case CPTScaleTypeLinear:
            plotPoint[CPTCoordinateY] = [self doublePrecisionPlotCoordinateForViewLength:point.y linearPlotRange:self.yRange boundsLength:boundsSize.height];
            break;

        case CPTScaleTypeLog:
            plotPoint[CPTCoordinateY] = [self doublePrecisionPlotCoordinateForViewLength:point.y logPlotRange:self.yRange boundsLength:boundsSize.height];
            break;

        default:
            [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
    }
}

// Plot area view point for event
-(CGPoint)plotAreaViewPointForEvent:(CPTNativeEvent *)event
{
    CGPoint plotAreaViewPoint = CGPointZero;

    CPTGraph *theGraph                  = self.graph;
    CPTGraphHostingView *theHostingView = theGraph.hostingView;
    CPTPlotArea *thePlotArea            = theGraph.plotAreaFrame.plotArea;

    if ( theHostingView && thePlotArea ) {
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        CGPoint interactionPoint = [[[event touchesForView:theHostingView] anyObject] locationInView:theHostingView];
        if ( theHostingView.collapsesLayers ) {
            plotAreaViewPoint.x = interactionPoint.x;
            plotAreaViewPoint.y = theHostingView.frame.size.height - interactionPoint.y;
        }
        else {
            plotAreaViewPoint = [theHostingView.layer convertPoint:interactionPoint toLayer:thePlotArea];
        }
#else
        CGPoint interactionPoint = NSPointToCGPoint([theHostingView convertPoint:[event locationInWindow] fromView:nil]);
        plotAreaViewPoint = [theHostingView.layer convertPoint:interactionPoint toLayer:thePlotArea];
#endif
    }

    return plotAreaViewPoint;
}

// Plot point for event
-(void)plotPoint:(NSDecimal *)plotPoint forEvent:(CPTNativeEvent *)event
{
    [self plotPoint:plotPoint forPlotAreaViewPoint:[self plotAreaViewPointForEvent:event]];
}

-(void)doublePrecisionPlotPoint:(double *)plotPoint forEvent:(CPTNativeEvent *)event
{
    [self doublePrecisionPlotPoint:plotPoint forPlotAreaViewPoint:[self plotAreaViewPointForEvent:event]];
}

/// @endcond

#pragma mark -
#pragma mark Scaling

/// @cond

-(void)scaleBy:(CGFloat)interactionScale aboutPoint:(CGPoint)plotAreaPoint
{
    if ( !self.graph.plotAreaFrame || (interactionScale <= 1.e-6) ) {
        return;
    }
    if ( ![self.graph.plotAreaFrame.plotArea containsPoint:plotAreaPoint] ) {
        return;
    }

    // Ask the delegate if it is OK
    BOOL shouldScale = YES;
    if ( [self.delegate respondsToSelector:@selector(plotSpace:shouldScaleBy:aboutPoint:)] ) {
        shouldScale = [self.delegate plotSpace:self shouldScaleBy:interactionScale aboutPoint:plotAreaPoint];
    }
    if ( !shouldScale ) {
        return;
    }

    // Determine point in plot coordinates
    NSDecimal const decimalScale = CPTDecimalFromCGFloat(interactionScale);
    NSDecimal plotInteractionPoint[2];
    [self plotPoint:plotInteractionPoint forPlotAreaViewPoint:plotAreaPoint];

    // Cache old ranges
    CPTPlotRange *oldRangeX = self.xRange;
    CPTPlotRange *oldRangeY = self.yRange;

    // Lengths are scaled by the pinch gesture inverse proportional
    NSDecimal newLengthX = CPTDecimalDivide(oldRangeX.length, decimalScale);
    NSDecimal newLengthY = CPTDecimalDivide(oldRangeY.length, decimalScale);

    // New locations
    NSDecimal newLocationX;
    if ( CPTDecimalGreaterThanOrEqualTo( oldRangeX.length, CPTDecimalFromInteger(0) ) ) {
        NSDecimal oldFirstLengthX = CPTDecimalSubtract(plotInteractionPoint[CPTCoordinateX], oldRangeX.minLimit); // x - minX
        NSDecimal newFirstLengthX = CPTDecimalDivide(oldFirstLengthX, decimalScale);                              // (x - minX) / scale
        newLocationX = CPTDecimalSubtract(plotInteractionPoint[CPTCoordinateX], newFirstLengthX);
    }
    else {
        NSDecimal oldSecondLengthX = CPTDecimalSubtract(oldRangeX.maxLimit, plotInteractionPoint[0]); // maxX - x
        NSDecimal newSecondLengthX = CPTDecimalDivide(oldSecondLengthX, decimalScale);                // (maxX - x) / scale
        newLocationX = CPTDecimalAdd(plotInteractionPoint[CPTCoordinateX], newSecondLengthX);
    }

    NSDecimal newLocationY;
    if ( CPTDecimalGreaterThanOrEqualTo( oldRangeY.length, CPTDecimalFromInteger(0) ) ) {
        NSDecimal oldFirstLengthY = CPTDecimalSubtract(plotInteractionPoint[CPTCoordinateY], oldRangeY.minLimit); // y - minY
        NSDecimal newFirstLengthY = CPTDecimalDivide(oldFirstLengthY, decimalScale);                              // (y - minY) / scale
        newLocationY = CPTDecimalSubtract(plotInteractionPoint[CPTCoordinateY], newFirstLengthY);
    }
    else {
        NSDecimal oldSecondLengthY = CPTDecimalSubtract(oldRangeY.maxLimit, plotInteractionPoint[1]); // maxY - y
        NSDecimal newSecondLengthY = CPTDecimalDivide(oldSecondLengthY, decimalScale);                // (maxY - y) / scale
        newLocationY = CPTDecimalAdd(plotInteractionPoint[CPTCoordinateY], newSecondLengthY);
    }

    // New ranges
    CPTPlotRange *newRangeX = [[[CPTPlotRange alloc] initWithLocation:newLocationX length:newLengthX] autorelease];
    CPTPlotRange *newRangeY = [[[CPTPlotRange alloc] initWithLocation:newLocationY length:newLengthY] autorelease];

    // Delegate may still veto/modify the range
    if ( [self.delegate respondsToSelector:@selector(plotSpace:willChangePlotRangeTo:forCoordinate:)] ) {
        newRangeX = [self.delegate plotSpace:self willChangePlotRangeTo:newRangeX forCoordinate:CPTCoordinateX];
        newRangeY = [self.delegate plotSpace:self willChangePlotRangeTo:newRangeY forCoordinate:CPTCoordinateY];
    }

    self.xRange = newRangeX;
    self.yRange = newRangeY;
}

/// @endcond

#pragma mark -
#pragma mark Interaction

/// @name User Interaction
/// @{

/**
 *  @brief Informs the receiver that the user has
 *  @if MacOnly pressed the mouse button. @endif
 *  @if iOSOnly touched the screen. @endif
 *
 *
 *  If the receiver has a @ref delegate and the delegate handles the event,
 *  this method always returns @YES.
 *  If @ref allowsUserInteraction is @NO
 *  or the graph does not have a @link CPTGraph::plotAreaFrame plotAreaFrame @endlink layer,
 *  this method always returns @NO.
 *  Otherwise, if the @par{interactionPoint} is within the bounds of the
 *  @link CPTGraph::plotAreaFrame plotAreaFrame @endlink, a drag operation starts and
 *  this method returns @YES.
 *
 *  @param event The OS event.
 *  @param interactionPoint The coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceDownEvent:(CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    BOOL handledByDelegate = [super pointingDeviceDownEvent:event atPoint:interactionPoint];

    if ( handledByDelegate ) {
        isDragging = NO;
        return YES;
    }

    if ( !self.allowsUserInteraction || !self.graph.plotAreaFrame ) {
        return NO;
    }

    CGPoint pointInPlotArea = [self.graph convertPoint:interactionPoint toLayer:self.graph.plotAreaFrame];
    if ( [self.graph.plotAreaFrame containsPoint:pointInPlotArea] ) {
        // Handle event
        lastDragPoint = pointInPlotArea;
        isDragging    = YES;
        return YES;
    }

    return NO;
}

/**
 *  @brief Informs the receiver that the user has
 *  @if MacOnly released the mouse button. @endif
 *  @if iOSOnly lifted their finger off the screen. @endif
 *
 *
 *  If the receiver has a @ref delegate and the delegate handles the event,
 *  this method always returns @YES.
 *  If @ref allowsUserInteraction is @NO
 *  or the graph does not have a @link CPTGraph::plotAreaFrame plotAreaFrame @endlink layer,
 *  this method always returns @NO.
 *  Otherwise, if a drag operation is in progress, it ends and
 *  this method returns @YES.
 *
 *  @param event The OS event.
 *  @param interactionPoint The coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceUpEvent:(CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    BOOL handledByDelegate = [super pointingDeviceUpEvent:event atPoint:interactionPoint];

    if ( handledByDelegate ) {
        return YES;
    }

    if ( !self.allowsUserInteraction || !self.graph.plotAreaFrame ) {
        return NO;
    }

    if ( isDragging ) {
        isDragging = NO;
        return YES;
    }

    return NO;
}

/**
 *  @brief Informs the receiver that the user has moved
 *  @if MacOnly the mouse with the button pressed. @endif
 *  @if iOSOnly their finger while touching the screen. @endif
 *
 *
 *  If the receiver has a @ref delegate and the delegate handles the event,
 *  this method always returns @YES.
 *  If @ref allowsUserInteraction is @NO
 *  or the graph does not have a @link CPTGraph::plotAreaFrame plotAreaFrame @endlink layer,
 *  this method always returns @NO.
 *  Otherwise, if a drag operation is in progress, the @ref xRange
 *  and @ref yRange are shifted to follow the drag and
 *  this method returns @YES.
 *
 *  @param event The OS event.
 *  @param interactionPoint The coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceDraggedEvent:(CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    BOOL handledByDelegate = [super pointingDeviceDraggedEvent:event atPoint:interactionPoint];

    if ( handledByDelegate ) {
        return YES;
    }

    if ( !self.allowsUserInteraction || !self.graph.plotAreaFrame ) {
        return NO;
    }

    if ( isDragging ) {
        CGPoint pointInPlotArea = [self.graph convertPoint:interactionPoint toLayer:self.graph.plotAreaFrame];
        CGPoint displacement    = CPTPointMake(pointInPlotArea.x - lastDragPoint.x, pointInPlotArea.y - lastDragPoint.y);
        CGPoint pointToUse      = pointInPlotArea;

        // Allow delegate to override
        if ( [self.delegate respondsToSelector:@selector(plotSpace:willDisplaceBy:)] ) {
            displacement = [self.delegate plotSpace:self willDisplaceBy:displacement];
            pointToUse   = CPTPointMake(lastDragPoint.x + displacement.x, lastDragPoint.y + displacement.y);
        }

        NSDecimal lastPoint[2], newPoint[2];
        [self plotPoint:lastPoint forPlotAreaViewPoint:lastDragPoint];
        [self plotPoint:newPoint forPlotAreaViewPoint:pointToUse];

        CPTMutablePlotRange *newRangeX = [[self.xRange mutableCopy] autorelease];
        CPTMutablePlotRange *newRangeY = [[self.yRange mutableCopy] autorelease];

        NSDecimal shiftX = CPTDecimalSubtract(lastPoint[0], newPoint[0]);
        NSDecimal shiftY = CPTDecimalSubtract(lastPoint[1], newPoint[1]);
        newRangeX.location = CPTDecimalAdd(newRangeX.location, shiftX);
        newRangeY.location = CPTDecimalAdd(newRangeY.location, shiftY);

        CPTPlotRange *globalX = self.globalXRange;
        if ( globalX ) {
            newRangeX = (CPTMutablePlotRange *)[self constrainRange:newRangeX toGlobalRange:globalX];
        }
        CPTPlotRange *globalY = self.globalYRange;
        if ( globalY ) {
            newRangeY = (CPTMutablePlotRange *)[self constrainRange:newRangeY toGlobalRange:globalY];
        }

        // Delegate override
        if ( [self.delegate respondsToSelector:@selector(plotSpace:willChangePlotRangeTo:forCoordinate:)] ) {
            self.xRange = [self.delegate plotSpace:self willChangePlotRangeTo:newRangeX forCoordinate:CPTCoordinateX];
            self.yRange = [self.delegate plotSpace:self willChangePlotRangeTo:newRangeY forCoordinate:CPTCoordinateY];
        }
        else {
            self.xRange = newRangeX;
            self.yRange = newRangeY;
        }

        lastDragPoint = pointInPlotArea;

        return YES;
    }

    return NO;
}

/// @}

@end
