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

- (id) initWithWindow:(GlkWindowState *)winref frame:(CGRect)box {
	self = [super initWithWindow:winref frame:box];
	if (self) {
		FizmoGlkViewController *glkviewc = [FizmoGlkViewController singleton];
		int val = glkviewc.fizmoDelegate.colorscheme;
		self.textview.indicatorStyle = (val==2 ? UIScrollViewIndicatorStyleWhite : UIScrollViewIndicatorStyleDefault);
	}
	return self;
}

- (void) uncacheLayoutAndStyles {
	[super uncacheLayoutAndStyles];

	FizmoGlkViewController *glkviewc = [FizmoGlkViewController singleton];
	int val = glkviewc.fizmoDelegate.colorscheme;
	self.textview.indicatorStyle = (val==2 ? UIScrollViewIndicatorStyleWhite : UIScrollViewIndicatorStyleDefault);
}

@end
