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
#import "PrefsMenuView.h"

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
	if (frameview.menuview && [frameview.menuview isKindOfClass:[PrefsMenuView class]]) {
		[frameview removePopMenuAnimated:YES];
		return;
	}
	
	CGRect rect = CGRectMake(4, 0, 40, 4);
	PrefsMenuView *menuview = [[[PrefsMenuView alloc] initWithFrame:frameview.bounds buttonFrame:rect belowButton:YES] autorelease];
	[frameview postPopMenu:menuview];
	
	/*
	CGFloat maxwidth = self.fizmoDelegate.maxwidth;
	if (maxwidth > 0)
		maxwidth = 0;
	else
		maxwidth = (self.view.bounds.size.width > 500) ? 600 : 280; //###
	
	self.fizmoDelegate.maxwidth = maxwidth;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setFloat:maxwidth forKey:@"FrameMaxWidth"];
	
	[self.frameview setNeedsLayout];
	 */
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
	//### different for iPad?
	return (orientation == UIInterfaceOrientationPortrait);
}

@end
