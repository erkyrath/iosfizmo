/* UnderlinedTextView.h: A UITextView subclass with underlined text
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UnderlinedTextView : UITextView

@property (nonatomic) BOOL animating;

- (CAShapeLayer *)createAnimationLayer;

@end

NS_ASSUME_NONNULL_END
