/* HelpViewController.m: Interpreter help tab view controller
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import "HelpViewController.h"
#import "IosGlkViewController.h"

@implementation HelpViewController

@synthesize webview;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
	}
	return self;
}

- (void) dealloc {
	if (webview) {
		webview.delegate = nil;
		self.webview = nil;
	}
	[super dealloc];
}

- (void) viewDidLoad
{
	NSLog(@"HelpVC: viewDidLoad");

	NSBundle *bundle = [NSBundle mainBundle];
	NSURL *url = [bundle URLForResource:@"index" withExtension:@"html" subdirectory:@"WebSite"];
	NSString *html = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
	[webview loadHTMLString:html baseURL:url];
	webview.delegate = self;

	if ([webview respondsToSelector:@selector(addGestureRecognizer:)]) {
		/* gestures are available in iOS 3.2 and up */
		UISwipeGestureRecognizer *recognizer;
		recognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)] autorelease];
		recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
		[webview addGestureRecognizer:recognizer];
		recognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)] autorelease];
		recognizer.direction = UISwipeGestureRecognizerDirectionRight;
		[webview addGestureRecognizer:recognizer];
	}
}

- (void) viewDidUnload
{
	NSLog(@"HelpVC: viewDidUnload");
}

- (void) handleSwipeLeft:(UIGestureRecognizer *)recognizer {
	if (self.tabBarController) {
		self.tabBarController.selectedIndex = 0;
	}
}

- (void) handleSwipeRight:(UIGestureRecognizer *)recognizer {
	if (self.tabBarController) {
		self.tabBarController.selectedIndex = 1;
	}
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
	IosGlkViewController *glkviewc = [IosGlkViewController singleton];
	return [glkviewc shouldAutorotateToInterfaceOrientation:orientation];
}

@end
