/* NotesViewController.m: Interpreter notes tab view controller
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import "NotesViewController.h"
#import "IosGlkViewController.h"

@implementation NotesViewController

@synthesize textview;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void) dealloc {
	self.textview = nil;
	[super dealloc];
}

- (void) viewDidLoad
{
	NSLog(@"NotesVC: viewDidLoad");
	
	//### bang on font if Noteworthy is not available
}

- (void) viewDidUnload
{
	NSLog(@"NotesVC: viewDidUnload");
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
	IosGlkViewController *glkviewc = [IosGlkViewController singleton];
	return [glkviewc shouldAutorotateToInterfaceOrientation:orientation];
}

@end
