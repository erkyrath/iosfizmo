/* SettingsViewController.h: Interpreter settings tab view controller
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import "SettingsViewController.h"
#import "FizmoGlkViewController.h"

@implementation SettingsViewController

@synthesize tableview;

- (void) dealloc {
	self.tableview = nil;
	[super dealloc];
}

- (void) viewDidLoad
{
	NSLog(@"SettingsVC: viewDidLoad");
	
	if ([tableview respondsToSelector:@selector(addGestureRecognizer:)]) {
		/* gestures are available in iOS 3.2 and up */
		
		FizmoGlkViewController *mainviewc = [FizmoGlkViewController singleton];
		UISwipeGestureRecognizer *recognizer;
		recognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:mainviewc action:@selector(handleSwipeLeft:)] autorelease];
		recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
		[tableview addGestureRecognizer:recognizer];
		recognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:mainviewc action:@selector(handleSwipeRight:)] autorelease];
		recognizer.direction = UISwipeGestureRecognizerDirectionRight;
		[tableview addGestureRecognizer:recognizer];
	}
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
	IosGlkViewController *glkviewc = [IosGlkViewController singleton];
	return [glkviewc shouldAutorotateToInterfaceOrientation:orientation];
}


@end
