#import "NSCoderExtensions.h"

#import "CPTUtilities.h"
#import "NSNumberExtensions.h"

void MyCGPathApplierFunc(void *info, const CGPathElement *element);

#pragma mark -

@implementation NSCoder(CPTExtensions)

#pragma mark -
#pragma mark Encoding

/** @brief Encodes a @ref CGFloat and associates it with the string @par{key}.
 *  @param number The number to encode.
 *  @param key The key to associate with the number.
 **/
-(void)encodeCGFloat:(CGFloat)number forKey:(NSString *)key
{
#if CGFLOAT_IS_DOUBLE
    [self encodeDouble:number forKey:key];
#else
    [self encodeFloat:number forKey:key];
#endif
}

/** @brief Encodes a @ref CGPoint and associates it with the string @par{key}.
 *  @param point The point to encode.
 *  @param key The key to associate with the point.
 **/
-(void)encodeCPTPoint:(CGPoint)point forKey:(NSString *)key
{
    NSString *newKey = [[NSString alloc] initWithFormat:@"%@.x", key];

    [self encodeCGFloat:point.x forKey:newKey];
    [newKey release];

    newKey = [[NSString alloc] initWithFormat:@"%@.y", key];
    [self encodeCGFloat:point.y forKey:newKey];
    [newKey release];
}

/** @brief Encodes a @ref CGSize and associates it with the string @par{key}.
 *  @param size The size to encode.
 *  @param key The key to associate with the size.
 **/
-(void)encodeCPTSize:(CGSize)size forKey:(NSString *)key
{
    NSString *newKey = [[NSString alloc] initWithFormat:@"%@.width", key];

    [self encodeCGFloat:size.width forKey:newKey];
    [newKey release];

    newKey = [[NSString alloc] initWithFormat:@"%@.height", key];
    [self encodeCGFloat:size.height forKey:newKey];
    [newKey release];
}

/** @brief Encodes a @ref CGRect and associates it with the string @par{key}.
 *  @param rect The rectangle to encode.
 *  @param key The key to associate with the rectangle.
 **/
-(void)encodeCPTRect:(CGRect)rect forKey:(NSString *)key
{
    NSString *newKey = [[NSString alloc] initWithFormat:@"%@.origin", key];

    [self encodeCPTPoint:rect.origin forKey:newKey];
    [newKey release];

    newKey = [[NSString alloc] initWithFormat:@"%@.size", key];
    [self encodeCPTSize:rect.size forKey:newKey];
    [newKey release];
}

/** @brief Encodes a color space and associates it with the string @par{key}.
 *  @param colorSpace The @ref CGColorSpaceRef to encode.
 *  @param key The key to associate with the color space.
 *  @note The current implementation only works with named color spaces.
 **/
-(void)encodeCGColorSpace:(CGColorSpaceRef)colorSpace forKey:(NSString *)key
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    NSLog(@"Color space encoding is not supported on iOS. Decoding will return a generic RGB color space.");
#else
    if ( colorSpace ) {
        CFDataRef iccProfile = CGColorSpaceCopyICCProfile(colorSpace);
        [self encodeObject:(NSData *)iccProfile forKey:key];
        CFRelease(iccProfile);
    }
#endif
}

/// @cond

void MyCGPathApplierFunc(void *info, const CGPathElement *element)
{
    NSMutableDictionary *elementData = [[NSMutableDictionary alloc] init];

    [elementData setObject:[NSNumber numberWithInt:element->type] forKey:@"type"];

    switch ( element->type ) {
        case kCGPathElementAddCurveToPoint: // 3 points
            [elementData setObject:[NSNumber numberWithCGFloat:element->points[2].x] forKey:@"point3.x"];
            [elementData setObject:[NSNumber numberWithCGFloat:element->points[2].y] forKey:@"point3.y"];

        case kCGPathElementAddQuadCurveToPoint: // 2 points
            [elementData setObject:[NSNumber numberWithCGFloat:element->points[1].x] forKey:@"point2.x"];
            [elementData setObject:[NSNumber numberWithCGFloat:element->points[1].y] forKey:@"point2.y"];

        case kCGPathElementMoveToPoint:    // 1 point
        case kCGPathElementAddLineToPoint: // 1 point
            [elementData setObject:[NSNumber numberWithCGFloat:element->points[0].x] forKey:@"point1.x"];
            [elementData setObject:[NSNumber numberWithCGFloat:element->points[0].y] forKey:@"point1.y"];
            break;

        case kCGPathElementCloseSubpath: // 0 points
            break;

        default:
            // unknown element type
            break;
    }

    NSMutableArray *pathData = (NSMutableArray *)info;
    [pathData addObject:elementData];

    [elementData release];
}

/// @endcond

/** @brief Encodes a path and associates it with the string @par{key}.
 *  @param path The @ref CGPathRef to encode.
 *  @param key The key to associate with the path.
 **/
-(void)encodeCGPath:(CGPathRef)path forKey:(NSString *)key
{
    NSMutableArray *pathData = [[NSMutableArray alloc] init];

    // walk the path and gather data for each element
    CGPathApply(path, pathData, &MyCGPathApplierFunc);

    // encode data count
    NSUInteger dataCount = pathData.count;
    NSString *newKey     = [[NSString alloc] initWithFormat:@"%@.count", key];
    [self encodeInteger:(NSInteger) dataCount forKey:newKey];
    [newKey release];

    // encode data elements
    for ( NSUInteger i = 0; i < dataCount; i++ ) {
        NSDictionary *elementData = [pathData objectAtIndex:i];

        CGPathElementType type = (CGPathElementType)[[elementData objectForKey:@"type"] intValue];
        newKey = [[NSString alloc] initWithFormat:@"%@[%lu].type", key, (unsigned long)i];
        [self encodeInt:type forKey:newKey];
        [newKey release];

        CGPoint point;

        switch ( type ) {
            case kCGPathElementAddCurveToPoint: // 3 points
                point.x = [[elementData objectForKey:@"point3.x"] cgFloatValue];
                point.y = [[elementData objectForKey:@"point3.y"] cgFloatValue];
                newKey  = [[NSString alloc] initWithFormat:@"%@[%lu].point3", key, (unsigned long)i];
                [self encodeCPTPoint:point forKey:newKey];
                [newKey release];

            case kCGPathElementAddQuadCurveToPoint: // 2 points
                point.x = [[elementData objectForKey:@"point2.x"] cgFloatValue];
                point.y = [[elementData objectForKey:@"point2.y"] cgFloatValue];
                newKey  = [[NSString alloc] initWithFormat:@"%@[%lu].point2", key, (unsigned long)i];
                [self encodeCPTPoint:point forKey:newKey];
                [newKey release];

            case kCGPathElementMoveToPoint:    // 1 point
            case kCGPathElementAddLineToPoint: // 1 point
                point.x = [[elementData objectForKey:@"point1.x"] cgFloatValue];
                point.y = [[elementData objectForKey:@"point1.y"] cgFloatValue];
                newKey  = [[NSString alloc] initWithFormat:@"%@[%lu].point1", key, (unsigned long)i];
                [self encodeCPTPoint:point forKey:newKey];
                [newKey release];
                break;

            case kCGPathElementCloseSubpath: // 0 points
                break;
        }
    }

    [pathData release];
}

/** @brief Encodes an image and associates it with the string @par{key}.
 *  @param image The @ref CGImageRef to encode.
 *  @param key The key to associate with the image.
 **/
-(void)encodeCGImage:(CGImageRef)image forKey:(NSString *)key
{
    NSString *newKey = [[NSString alloc] initWithFormat:@"%@.width", key];

    [self encodeInt64:(int64_t)CGImageGetWidth(image) forKey:newKey];
    [newKey release];

    newKey = [[NSString alloc] initWithFormat:@"%@.height", key];
    [self encodeInt64:(int64_t)CGImageGetHeight(image) forKey:newKey];
    [newKey release];

    newKey = [[NSString alloc] initWithFormat:@"%@.bitsPerComponent", key];
    [self encodeInt64:(int64_t)CGImageGetBitsPerComponent(image) forKey:newKey];
    [newKey release];

    newKey = [[NSString alloc] initWithFormat:@"%@.bitsPerPixel", key];
    [self encodeInt64:(int64_t)CGImageGetBitsPerPixel(image) forKey:newKey];
    [newKey release];

    newKey = [[NSString alloc] initWithFormat:@"%@.bytesPerRow", key];
    [self encodeInt64:(int64_t)CGImageGetBytesPerRow(image) forKey:newKey];
    [newKey release];

    newKey = [[NSString alloc] initWithFormat:@"%@.colorSpace", key];
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image);
    [self encodeCGColorSpace:colorSpace forKey:newKey];
    [newKey release];

    newKey = [[NSString alloc] initWithFormat:@"%@.bitmapInfo", key];
    [self encodeInt32:(int32_t)CGImageGetBitmapInfo(image) forKey:newKey];
    [newKey release];

    CGDataProviderRef provider = CGImageGetDataProvider(image);
    CFDataRef providerData     = CGDataProviderCopyData(provider);
    newKey = [[NSString alloc] initWithFormat:@"%@.provider", key];
    [self encodeObject:(NSData *)providerData forKey:newKey];
    if ( providerData ) {
        CFRelease(providerData);
    }
    [newKey release];

    const CGFloat *decodeArray = CGImageGetDecode(image);
    if ( decodeArray ) {
        size_t numberOfComponents = CGColorSpaceGetNumberOfComponents(colorSpace);
        newKey = [[NSString alloc] initWithFormat:@"%@.numberOfComponents", key];
        [self encodeInt64:(int64_t) numberOfComponents forKey:newKey];
        [newKey release];

        for ( size_t i = 0; i < numberOfComponents; i++ ) {
            newKey = [[NSString alloc] initWithFormat:@"%@.decode[%zu].lower", key, i];
            [self encodeCGFloat:decodeArray[i * 2] forKey:newKey];
            [newKey release];

            newKey = [[NSString alloc] initWithFormat:@"%@.decode[%zu].upper", key, i];
            [self encodeCGFloat:decodeArray[i * 2 + 1] forKey:newKey];
            [newKey release];
        }
    }

    newKey = [[NSString alloc] initWithFormat:@"%@.shouldInterpolate", key];
    [self encodeBool:CGImageGetShouldInterpolate(image) forKey:newKey];
    [newKey release];

    newKey = [[NSString alloc] initWithFormat:@"%@.renderingIntent", key];
    [self encodeInt:CGImageGetRenderingIntent(image) forKey:newKey];
    [newKey release];
}

/** @brief Encodes an @ref NSDecimal and associates it with the string @par{key}.
 *  @param number The number to encode.
 *  @param key The key to associate with the number.
 **/
-(void)encodeDecimal:(NSDecimal)number forKey:(NSString *)key
{
    [self encodeObject:[NSDecimalNumber decimalNumberWithDecimal:number] forKey:key];
}

#pragma mark -
#pragma mark Decoding

/** @brief Decodes and returns a number that was previously encoded with
 *  @link NSCoder::encodeCGFloat:forKey: -encodeCGFloat:forKey: @endlink
 *  and associated with the string @par{key}.
 *  @param key The key associated with the number.
 *  @return The number as a @ref CGFloat.
 **/
-(CGFloat)decodeCGFloatForKey:(NSString *)key
{
#if CGFLOAT_IS_DOUBLE
    return [self decodeDoubleForKey:key];

#else
    return [self decodeFloatForKey:key];
#endif
}

/** @brief Decodes and returns a point that was previously encoded with
 *  @link NSCoder::encodeCPTPoint:forKey: -encodeCPTPoint:forKey: @endlink
 *  and associated with the string @par{key}.
 *  @param key The key associated with the point.
 *  @return The point.
 **/
-(CGPoint)decodeCPTPointForKey:(NSString *)key
{
    CGPoint point;

    NSString *newKey = [[NSString alloc] initWithFormat:@"%@.x", key];

    point.x = [self decodeCGFloatForKey:newKey];
    [newKey release];

    newKey  = [[NSString alloc] initWithFormat:@"%@.y", key];
    point.y = [self decodeCGFloatForKey:newKey];
    [newKey release];

    return point;
}

/** @brief Decodes and returns a size that was previously encoded with
 *  @link NSCoder::encodeCPTSize:forKey: -encodeCPTSize:forKey:@endlink
 *  and associated with the string @par{key}.
 *  @param key The key associated with the size.
 *  @return The size.
 **/
-(CGSize)decodeCPTSizeForKey:(NSString *)key
{
    CGSize size;

    NSString *newKey = [[NSString alloc] initWithFormat:@"%@.width", key];

    size.width = [self decodeCGFloatForKey:newKey];
    [newKey release];

    newKey      = [[NSString alloc] initWithFormat:@"%@.height", key];
    size.height = [self decodeCGFloatForKey:newKey];
    [newKey release];

    return size;
}

/** @brief Decodes and returns a rectangle that was previously encoded with
 *  @link NSCoder::encodeCPTRect:forKey: -encodeCPTRect:forKey:@endlink
 *  and associated with the string @par{key}.
 *  @param key The key associated with the rectangle.
 *  @return The rectangle.
 **/
-(CGRect)decodeCPTRectForKey:(NSString *)key
{
    CGRect rect;

    NSString *newKey = [[NSString alloc] initWithFormat:@"%@.origin", key];

    rect.origin = [self decodeCPTPointForKey:newKey];
    [newKey release];

    newKey    = [[NSString alloc] initWithFormat:@"%@.size", key];
    rect.size = [self decodeCPTSizeForKey:newKey];
    [newKey release];

    return rect;
}

/** @brief Decodes and returns an new color space object that was previously encoded with
 *  @link NSCoder::encodeCGColorSpace:forKey: -encodeCGColorSpace:forKey:@endlink
 *  and associated with the string @par{key}.
 *  @param key The key associated with the color space.
 *  @return The new path.
 *  @note The current implementation only works with named color spaces.
 **/
-(CGColorSpaceRef)newCGColorSpaceDecodeForKey:(NSString *)key
{
    CGColorSpaceRef colorSpace = NULL;

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    NSLog(@"Color space decoding is not supported on iOS. Using generic RGB color space.");
    colorSpace = CGColorSpaceCreateDeviceRGB();
#else
    NSData *iccProfile = [self decodeObjectForKey:key];
    if ( iccProfile ) {
        colorSpace = CGColorSpaceCreateWithICCProfile( (CFDataRef)iccProfile );
    }
    else {
        NSLog(@"Color space not available for key '%@'. Using generic RGB color space.", key);
        colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    }
#endif

    return colorSpace;
}

/** @brief Decodes and returns a new path object that was previously encoded with
 *  @link NSCoder::encodeCGPath:forKey: -encodeCGPath:forKey:@endlink
 *  and associated with the string @par{key}.
 *  @param key The key associated with the path.
 *  @return The new path.
 **/
-(CGPathRef)newCGPathDecodeForKey:(NSString *)key
{
    CGMutablePathRef newPath = CGPathCreateMutable();

    // decode count
    NSString *newKey = [[NSString alloc] initWithFormat:@"%@.count", key];
    NSUInteger count = (NSUInteger)[self decodeIntegerForKey : newKey];

    [newKey release];

    // decode elements
    for ( NSUInteger i = 0; i < count; i++ ) {
        newKey = [[NSString alloc] initWithFormat:@"%@[%lu].type", key, (unsigned long)i];
        CGPathElementType type = (CGPathElementType)[self decodeIntForKey : newKey];
        [newKey release];

        CGPoint point1, point2, point3;

        switch ( type ) {
            case kCGPathElementAddCurveToPoint: // 3 points
                newKey = [[NSString alloc] initWithFormat:@"%@[%lu].point3", key, (unsigned long)i];
                point3 = [self decodeCPTPointForKey:newKey];
                [newKey release];

            case kCGPathElementAddQuadCurveToPoint: // 2 points
                newKey = [[NSString alloc] initWithFormat:@"%@[%lu].point2", key, (unsigned long)i];
                point2 = [self decodeCPTPointForKey:newKey];
                [newKey release];

            case kCGPathElementMoveToPoint:    // 1 point
            case kCGPathElementAddLineToPoint: // 1 point
                newKey = [[NSString alloc] initWithFormat:@"%@[%lu].point1", key, (unsigned long)i];
                point1 = [self decodeCPTPointForKey:newKey];
                [newKey release];
                break;

            case kCGPathElementCloseSubpath: // 0 points
                break;

            default:
                // unknown element type
                break;
        }

        switch ( type ) {
            case kCGPathElementMoveToPoint:
                CGPathMoveToPoint(newPath, NULL, point1.x, point1.y);
                break;

            case kCGPathElementAddLineToPoint:
                CGPathAddLineToPoint(newPath, NULL, point1.x, point1.y);
                break;

            case kCGPathElementAddQuadCurveToPoint:
                CGPathAddQuadCurveToPoint(newPath, NULL, point1.x, point1.y, point2.x, point2.y);
                break;

            case kCGPathElementAddCurveToPoint:
                CGPathAddCurveToPoint(newPath, NULL, point1.x, point1.y, point2.x, point2.y, point3.x, point3.y);
                break;

            case kCGPathElementCloseSubpath:
                CGPathCloseSubpath(newPath);
                break;

            default:
                // unknown element type
                break;
        }
    }

    return newPath;
}

/** @brief Decodes and returns a new image object that was previously encoded with
 *  @link NSCoder::encodeCGImage:forKey: -encodeCGImage:forKey:@endlink
 *  and associated with the string @par{key}.
 *  @param key The key associated with the image.
 *  @return The new image.
 **/
-(CGImageRef)newCGImageDecodeForKey:(NSString *)key
{
    NSString *newKey = [[NSString alloc] initWithFormat:@"%@.width", key];
    size_t width     = (size_t)[self decodeInt64ForKey : newKey];

    [newKey release];

    newKey = [[NSString alloc] initWithFormat:@"%@.height", key];
    size_t height = (size_t)[self decodeInt64ForKey : newKey];
    [newKey release];

    newKey = [[NSString alloc] initWithFormat:@"%@.bitsPerComponent", key];
    size_t bitsPerComponent = (size_t)[self decodeInt64ForKey : newKey];
    [newKey release];

    newKey = [[NSString alloc] initWithFormat:@"%@.bitsPerPixel", key];
    size_t bitsPerPixel = (size_t)[self decodeInt64ForKey : newKey];
    [newKey release];

    newKey = [[NSString alloc] initWithFormat:@"%@.bytesPerRow", key];
    size_t bytesPerRow = (size_t)[self decodeInt64ForKey : newKey];
    [newKey release];

    newKey = [[NSString alloc] initWithFormat:@"%@.colorSpace", key];
    CGColorSpaceRef colorSpace = [self newCGColorSpaceDecodeForKey:newKey];
    [newKey release];

    newKey = [[NSString alloc] initWithFormat:@"%@.bitmapInfo", key];
    CGBitmapInfo bitmapInfo = (CGBitmapInfo)[self decodeInt32ForKey : newKey];
    [newKey release];

    newKey = [[NSString alloc] initWithFormat:@"%@.provider", key];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData( (CFDataRef)[self decodeObjectForKey: newKey] );
    [newKey release];

    newKey = [[NSString alloc] initWithFormat:@"%@.numberOfComponents", key];
    size_t numberOfComponents = (size_t)[self decodeInt64ForKey : newKey];
    [newKey release];

    CGFloat *decodeArray = NULL;
    if ( numberOfComponents ) {
        decodeArray = malloc( numberOfComponents * 2 * sizeof(CGFloat) );

        for ( size_t i = 0; i < numberOfComponents; i++ ) {
            newKey             = [[NSString alloc] initWithFormat:@"%@.decode[%zu].lower", key, i];
            decodeArray[i * 2] = [self decodeCGFloatForKey:newKey];
            [newKey release];

            newKey                 = [[NSString alloc] initWithFormat:@"%@.decode[%zu].upper", key, i];
            decodeArray[i * 2 + 1] = [self decodeCGFloatForKey:newKey];
            [newKey release];
        }
    }

    newKey = [[NSString alloc] initWithFormat:@"%@.shouldInterpolate", key];
    bool shouldInterpolate = [self decodeBoolForKey:newKey];
    [newKey release];

    newKey = [[NSString alloc] initWithFormat:@"%@.renderingIntent", key];
    CGColorRenderingIntent intent = (CGColorRenderingIntent)[self decodeIntForKey : newKey];
    [newKey release];

    CGImageRef newImage = CGImageCreate(width,
                                        height,
                                        bitsPerComponent,
                                        bitsPerPixel,
                                        bytesPerRow,
                                        colorSpace,
                                        bitmapInfo,
                                        provider,
                                        decodeArray,
                                        shouldInterpolate,
                                        intent);

    CGColorSpaceRelease(colorSpace);
    CGDataProviderRelease(provider);
    if ( decodeArray ) {
        free(decodeArray);
    }

    return newImage;
}

/** @brief Decodes and returns a decimal number that was previously encoded with
 *  @link NSCoder::encodeDecimal:forKey: -encodeDecimal:forKey:@endlink
 *  and associated with the string @par{key}.
 *  @param key The key associated with the number.
 *  @return The number as an @ref NSDecimal.
 **/
-(NSDecimal)decodeDecimalForKey:(NSString *)key
{
    NSDecimal result;

    NSNumber *number = [self decodeObjectForKey:key];

    if ( [number respondsToSelector:@selector(decimalValue)] ) {
        result = [number decimalValue];
    }
    else {
        result = CPTDecimalNaN();
    }

    return result;
}

@end
