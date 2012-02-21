/* PrefsMenuView.m: A popmenu subclass that can display the preferences menu
 for IosGlk, the iOS implementation of the Glk API.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import "PrefsMenuView.h"
#import "FizmoGlkViewController.h"
#import "FizmoGlkDelegate.h"

@implementation PrefsMenuView

@synthesize container;

- (void) loadContent {
	[[NSBundle mainBundle] loadNibNamed:@"PrefsMenuView" owner:self options:nil];
	[self resizeContentTo:container.frame.size animated:YES];
	[content addSubview:container];
}

- (IBAction) handleColumnWidth:(id)sender {
	FizmoGlkViewController *glkviewc = [FizmoGlkViewController singleton];
	
	CGFloat maxwidth;
	
	UIView *senderview = sender;
	switch (senderview.tag) {
		case 2:
			maxwidth = 624;
			break;
		case 3:
			maxwidth = 512;
			break;
		default:
			maxwidth = 0;
			break;
	}
	
	glkviewc.fizmoDelegate.maxwidth = maxwidth;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setFloat:maxwidth forKey:@"FrameMaxWidth"];
	
	[glkviewc.frameview setNeedsLayout];
}

@end

@implementation PrefsContainerView

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}

@end
