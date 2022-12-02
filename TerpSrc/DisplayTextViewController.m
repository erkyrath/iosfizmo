/* DisplayTextViewController.m: Transcript display view controller
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import "DisplayTextViewController.h"
#import "IosGlkViewController.h"
#import "RelDateFormatter.h"
#import "GlkFileTypes.h"
#import "IosGlkAppDelegate.h"

@implementation DisplayTextViewController

@synthesize textview;
@synthesize titlelabel;
@synthesize datelabel;
@synthesize thumb;

- (instancetype) initWithNibName:(NSString *)nibName thumb:(GlkFileThumb *)thumbref bundle:(NSBundle *)nibBundle
{
	self = [super initWithNibName:nibName bundle:nibBundle];
	if (self) {
		self.edgesForExtendedLayout = 0; // avoid navbar underrun
		self.thumb = thumbref;
	}
	return self;
}


- (void) viewDidLoad
{
	[super viewDidLoad];

	self.navigationItem.title = NSLocalizedStringFromTable(@"title.transcript", @"TerpLocalize", nil);

	UIBarButtonItem *sendbutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(buttonSend:)];
	self.navigationItem.rightBarButtonItem = sendbutton;

	titlelabel.text = thumb.label;

//	if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
//		/* No room for this on the iphone layout */
//		datelabel.hidden = YES;
//	}
//	else {
		RelDateFormatter *dateformatter = [[RelDateFormatter alloc] init];
		dateformatter.dateStyle = NSDateFormatterMediumStyle;
		dateformatter.timeStyle = NSDateFormatterShortStyle;
		datelabel.text = [dateformatter stringFromDate:thumb.modtime];
//	}

	NSString *str = [NSString stringWithContentsOfFile:thumb.pathname encoding:NSUTF8StringEncoding error:nil];
	if (str)
		textview.text = str;

	if (true) {
		UISwipeGestureRecognizer *recognizer;
		recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
		recognizer.direction = UISwipeGestureRecognizerDirectionRight;
		[textview addGestureRecognizer:recognizer];
	}
}

- (void) handleSwipeRight:(UIGestureRecognizer *)recognizer {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) buttonSend:(id)sender
{
		NSArray *ls = @[textview.text];
		UIActivityViewController *actvc = [[UIActivityViewController alloc] initWithActivityItems:ls applicationActivities:nil];
		if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
			[self presentViewController:actvc animated:YES completion:nil];
		}
		return;
	}

@end
