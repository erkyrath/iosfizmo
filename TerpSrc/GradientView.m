/* GradientView.m: A view that just displays a color gradient
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import "GradientView.h"


@implementation GradientView

@synthesize numcolors;
@synthesize color0;
@synthesize color1;
@synthesize color2;
@synthesize color3;
@synthesize color4;

+ (Class) layerClass {
	return [CAGradientLayer class];
}

- (BOOL) hasColors {
	if (numcolors == 0)
		return NO;
	if (numcolors > 0 && !color0)
		return NO;
	if (numcolors > 1 && !color1)
		return NO;
	if (numcolors > 2 && !color2)
		return NO;
	if (numcolors > 3 && !color3)
		return NO;
	if (numcolors > 4 && !color4)
		return NO;
	return YES;
}

- (void) setUpColorsPreset:(int)val {
	switch (val) {
		case 1:
			self.color0 = [UIColor colorNamed:@"CustomNoteBackground1"];
            self.color1 = [UIColor colorNamed:@"CustomNoteBackground2"];
            self.color2 = [UIColor colorNamed:@"CustomNoteBackground3"];
			self.color3 = self.color1;
			self.color4 = self.color0;
			numcolors = 5;
			break;
		default:
			return;
	}

	self.backgroundColor = nil;

	CAGradientLayer *layer = (CAGradientLayer *)self.layer;

	layer.startPoint = CGPointMake(0.0, 0.5);
	layer.endPoint   = CGPointMake(1.0, 0.5);

	switch (numcolors) {
		case 2:
			layer.colors = @[(id)color0.CGColor,
							(id)color1.CGColor];
			break;

		case 3:
			layer.colors = @[(id)color0.CGColor,
							(id)color1.CGColor,
							(id)color2.CGColor];
			break;

		case 4:
			layer.colors = @[(id)color0.CGColor,
							(id)color1.CGColor,
							(id)color2.CGColor,
							(id)color3.CGColor];
			break;

		case 5:
			layer.colors = @[(id)color0.CGColor,
							(id)color1.CGColor,
							(id)color2.CGColor,
							(id)color3.CGColor,
							(id)color4.CGColor];
			break;
	}
}

@end
