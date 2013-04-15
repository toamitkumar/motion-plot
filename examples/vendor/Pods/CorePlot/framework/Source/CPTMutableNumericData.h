#import "CPTNumericData.h"
#import "CPTNumericDataType.h"
#import <Foundation/Foundation.h>

@interface CPTMutableNumericData : CPTNumericData {
}

/// @name Data Buffer
/// @{
@property (readonly) void *mutableBytes;
/// @}

/// @name Dimensions
/// @{
@property (copy, readwrite) NSArray *shape;
/// @}

@end
