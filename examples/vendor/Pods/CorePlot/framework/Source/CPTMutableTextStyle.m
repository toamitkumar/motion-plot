#import "CPTMutableTextStyle.h"

#import "CPTColor.h"

/** @brief Mutable wrapper for text style properties.
 *
 *  Use this whenever you need to customize the properties of a text style.
 **/

@implementation CPTMutableTextStyle

/** @property CGFloat fontSize
 *  @brief The font size. Default is @num{12.0}.
 **/
@dynamic fontSize;

/** @property NSString *fontName
 *  @brief The font name. Default is Helvetica.
 **/
@dynamic fontName;

/** @property CPTColor *color
 *  @brief The current text color. Default is solid black.
 **/
@dynamic color;

/** @property CPTTextAlignment textAlignment
 *  @brief The paragraph alignment for multi-line text. Default is #CPTTextAlignmentLeft.
 **/
@dynamic textAlignment;

@end
