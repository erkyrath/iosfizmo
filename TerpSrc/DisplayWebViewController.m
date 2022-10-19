/* DisplayWebViewController.h: HTML Display view controller
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import "DisplayWebViewController.h"
#import "IosGlkViewController.h"
#import "FizmoGlkViewController.h"
#import "IosGlkAppDelegate.h"

@implementation DisplayWebViewController

@synthesize webview;
@synthesize filename;
@synthesize doctitle;

- (instancetype) initWithNibName:(NSString *)nibName filename:(NSString *)fileref title:(NSString *)titleref bundle:(NSBundle *)nibBundle
{
	self = [super initWithNibName:nibName bundle:nibBundle];
	if (self) {
		self.edgesForExtendedLayout = 0; // avoid navbar underrun
		self.filename = fileref;
		self.doctitle = titleref;
	}
	return self;
}

- (void) dealloc {
	if (webview) {
		webview.navigationDelegate = nil;
	}
}

- (void) viewDidLoad
{
	[super viewDidLoad];

	self.navigationItem.title = doctitle;

	NSBundle *bundle = [NSBundle mainBundle];
	// Do this the annoying iOS3-compatible way
	NSString *path = [bundle pathForResource:filename ofType:@"html" inDirectory:@"WebSite"];
	NSURL *url = [NSURL fileURLWithPath:path isDirectory:NO];
	NSString *html = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
	[webview loadHTMLString:html baseURL:url];
	webview.navigationDelegate = self;

	if (true) {
		UISwipeGestureRecognizer *recognizer;
		recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
		recognizer.direction = UISwipeGestureRecognizerDirectionRight;
		[webview addGestureRecognizer:recognizer];
	}
}

- (void) handleSwipeRight:(UIGestureRecognizer *)recognizer {
	[self.navigationController popViewControllerAnimated:YES];
}

/* Ensure that all external URLs are sent to Safari. (UIWebView delegate method.)
 */
- (BOOL) webView:(WKWebView *)webView decidePolicyForNavigationAction:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if ((request.URL).fileURL) {
		/* Let file:... URLs load normally */
		return YES;
	}

    [[UIApplication sharedApplication] openURL:request.URL options:@{} completionHandler:nil];
	return NO;
}

@end

