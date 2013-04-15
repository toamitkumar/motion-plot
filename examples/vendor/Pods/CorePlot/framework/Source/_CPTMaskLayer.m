#import "_CPTMaskLayer.h"

/**
 *  @brief A utility layer used to mask the borders on other layers.
 **/
@implementation CPTMaskLayer

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Initializes a newly allocated CPTMaskLayer object with the provided frame rectangle.
 *
 *	This is the designated initializer. The initialized layer will have the following properties:
 *	- @ref needsDisplayOnBoundsChange = @YES
 *
 *	@param newFrame The frame rectangle.
 *  @return The initialized CPTMaskLayer object.
 **/
-(id)initWithFrame:(CGRect)newFrame
{
    if ( (self = [super initWithFrame:newFrame]) ) {
        self.needsDisplayOnBoundsChange = YES;
    }
    return self;
}

#pragma mark -
#pragma mark Drawing

/// @cond

-(void)renderAsVectorInContext:(CGContextRef)context
{
    [super renderAsVectorInContext:context];

    CPTLayer *theMaskedLayer = (CPTLayer *)self.superlayer;

    if ( theMaskedLayer ) {
        CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);

        if ( [theMaskedLayer isKindOfClass:[CPTLayer class]] ) {
            CGPathRef maskingPath = theMaskedLayer.sublayerMaskingPath;

            if ( maskingPath ) {
                CGContextAddPath(context, maskingPath);
                CGContextFillPath(context);
            }
        }
        else {
            CGContextFillRect(context, self.bounds);
        }
    }
}

/// @endcond

@end
