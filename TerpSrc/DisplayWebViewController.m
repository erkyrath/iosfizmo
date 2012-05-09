/* DisplayWebViewController.h: HTML Display view controller
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import "DisplayWebViewController.h"
#import "IosGlkViewController.h"
#import "FizmoGlkViewController.h"

@implementation DisplayWebViewController

@synthesize webview;
@synthesize filename;
@synthesize doctitle;

- (id) initWithNibName:(NSString *)nibName filename:(NSString *)fileref title:(NSString *)titleref bundle:(NSBundle *)nibBundle
{
	self = [super initWithNibName:nibName bundle:nibBundle];
	if (self) {
		self.filename = fileref;
		self.doctitle = titleref;
	}
	return self;
}

- (void) dealloc {
	self.filename = nil;
	self.doctitle = nil;
	if (webview) {
		webview.delegate = nil;
		self.webview = nil;
	}
	[super dealloc];
}

- (void) viewDidLoad
{
	self.navigationItem.title = doctitle;

	NSBundle *bundle = [NSBundle mainBundle];
	NSURL *url = [bundle URLForResource:filename withExtension:@"html" subdirectory:@"WebSite"];
	NSString *html = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
	[webview loadHTMLString:html baseURL:url];
	webview.delegate = self;

	if ([webview respondsToSelector:@selector(addGestureRecognizer:)]) {
		/* gestures are available in iOS 3.2 and up */
		UISwipeGestureRecognizer *recognizer;
		recognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)] autorelease];
		recognizer.direction = UISwipeGestureRecognizerDirectionRight;
		[webview addGestureRecognizer:recognizer];
	}
}

- (void) handleSwipeRight:(UIGestureRecognizer *)recognizer {
	[self.navigationController popViewControllerAnimated:YES];
}

/* Ensure that all external URLs are sent to Safari. (UIWebView delegate method.)
 */
- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if ([request.URL isFileURL]) {
		/* Let file:... URLs load normally */
		return YES;
	}
	
	[[UIApplication sharedApplication] openURL:request.URL];
	return NO;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
	IosGlkViewController *glkviewc = [IosGlkViewController singleton];
	return [glkviewc shouldAutorotateToInterfaceOrientation:orientation];
}

@end

