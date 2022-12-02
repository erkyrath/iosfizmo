/* GradientView.h: A view that just displays a color gradient
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import <UIKit/UIKit.h>


@interface GradientView : UIView {
	int numcolors;
	UIColor *color0;
	UIColor *color1;
	UIColor *color2;
	UIColor *color3;
	UIColor *color4;
}

@property (nonatomic) int numcolors;
@property (nonatomic, strong) UIColor *color0;
@property (nonatomic, strong) UIColor *color1;
@property (nonatomic, strong) UIColor *color2;
@property (nonatomic, strong) UIColor *color3;
@property (nonatomic, strong) UIColor *color4;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasColors;
- (void) setUpColorsPreset:(int)val;

@end
