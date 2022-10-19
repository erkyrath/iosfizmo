/* FizmoGlkWindows.m: Fizmo-specific window buffer subclasses, for the IosGlk library
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import "FizmoGlkWindows.h"
#import "StyledTextView.h"
#import "FizmoGlkViewController.h"
#import "FizmoGlkDelegate.h"

@implementation FizmoGlkWinBufferView

- (instancetype) initWithWindow:(GlkWindowState *)winref frame:(CGRect)box margin:(UIEdgeInsets)margin {
	self = [super initWithWindow:winref frame:box margin:margin];
	if (self) {
		FizmoGlkViewController *glkviewc = [FizmoGlkViewController singleton];
		BOOL isdark = glkviewc.fizmoDelegate.hasDarkTheme;
		self.textview.indicatorStyle = (isdark ? UIScrollViewIndicatorStyleWhite : UIScrollViewIndicatorStyleDefault);
	}
	return self;
}

- (void) uncacheLayoutAndStyles {
	[super uncacheLayoutAndStyles];

	FizmoGlkViewController *glkviewc = [FizmoGlkViewController singleton];
	BOOL isdark = glkviewc.fizmoDelegate.hasDarkTheme;
	self.textview.indicatorStyle = (isdark ? UIScrollViewIndicatorStyleWhite : UIScrollViewIndicatorStyleDefault);
}

@end
