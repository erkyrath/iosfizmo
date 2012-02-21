/* PrefsMenuView.m: A popmenu subclass that can display the preferences menu
 for IosGlk, the iOS implementation of the Glk API.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import "PrefsMenuView.h"

@implementation PrefsMenuView

@synthesize container;

- (void) loadContent {
	[[NSBundle mainBundle] loadNibNamed:@"PrefsMenuView" owner:self options:nil];
	[self resizeContentTo:container.frame.size animated:YES];
	[content addSubview:container];
}

@end

@implementation PrefsContainerView

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}

@end
