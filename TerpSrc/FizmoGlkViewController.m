/* FizmoGlkViewController.m: Fizmo-specific subclass of the IosGlk view controller
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import "FizmoGlkViewController.h"
#import "FizmoGlkDelegate.h"
#import "IosGlkAppDelegate.h"
#import "GlkFrameView.h"
#import "GlkWinBufferView.h"
#import "NotesViewController.h"
#import "PrefsMenuView.h"

@implementation FizmoGlkViewController

@synthesize notesvc;

+ (FizmoGlkViewController *) singleton {
	return (FizmoGlkViewController *)([IosGlkAppDelegate singleton].glkviewc);
}

- (FizmoGlkDelegate *) fizmoDelegate {
	return (FizmoGlkDelegate *)self.glkdelegate;
}

- (void) didFinishLaunching {
	[super didFinishLaunching];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	CGFloat maxwidth = [defaults floatForKey:@"FrameMaxWidth"];
	self.fizmoDelegate.maxwidth = maxwidth;
	
	/* Font-scale values are arbitrarily between 1 and 5. */
	int fontscale = [defaults integerForKey:@"FontScale"];
	if (fontscale == 0)
		fontscale = 3;
	self.fizmoDelegate.fontscale = fontscale;
	
	/* Color-scheme values are 0 to 2. */
	int colorscheme = [defaults integerForKey:@"ColorScheme"];
	self.fizmoDelegate.colorscheme = colorscheme;
	
	NSString *fontfamily = [defaults stringForKey:@"FontFamily"];
	if (!fontfamily)
		fontfamily = @"Georgia";
	self.fizmoDelegate.fontfamily = fontfamily;
	
	self.navigationController.navigationBar.barStyle = (colorscheme==2 ? UIBarStyleBlack : UIBarStyleDefault);
	self.frameview.backgroundColor = [self.fizmoDelegate genBackgroundColor];
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
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
	//### different for iPad?
	return (orientation == UIInterfaceOrientationPortrait);
}

@end
