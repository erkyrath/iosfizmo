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
}

- (void) viewDidUnload
{
	NSLog(@"HelpVC: viewDidUnload");
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
	IosGlkViewController *glkviewc = [IosGlkViewController singleton];
	return [glkviewc shouldAutorotateToInterfaceOrientation:orientation];
}

@end
