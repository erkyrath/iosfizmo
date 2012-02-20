/* FizmoGlkViewController.m: Fizmo-specific subclass of the IosGlk view controller
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import "FizmoGlkViewController.h"
#import "FizmoGlkDelegate.h"
#import "GlkFrameView.h"
#import "GlkWinBufferView.h"
#import "NotesViewController.h"

@implementation FizmoGlkViewController

@synthesize notesvc;

- (FizmoGlkDelegate *) fizmoDelegate {
	return (FizmoGlkDelegate *)self.glkdelegate;
}

- (void) didFinishLaunching {
	[super didFinishLaunching];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	CGFloat maxwidth = [defaults floatForKey:@"FrameMaxWidth"];
	self.fizmoDelegate.maxwidth = maxwidth;
}

- (void) becameInactive {
	[notesvc saveIfNeeded];
}

- (IBAction) showPreferences {
	NSLog(@"### preferences");
	CGFloat maxwidth = self.fizmoDelegate.maxwidth;
	if (maxwidth > 0)
		maxwidth = 0;
	else
		maxwidth = (self.view.bounds.size.width > 500) ? 600 : 280; //###
	
	self.fizmoDelegate.maxwidth = maxwidth;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setFloat:maxwidth forKey:@"FrameMaxWidth"];
	
	[self.frameview setNeedsLayout];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
	//### different for iPad?
	return (orientation == UIInterfaceOrientationPortrait);
}

@end
