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

- (id) initWithNibName:(NSString *)nibName thumb:(GlkFileThumb *)thumbref bundle:(NSBundle *)nibBundle
{
	self = [super initWithNibName:nibName bundle:nibBundle];
	if (self) {
		self.thumb = thumbref;
	}
	return self;
}

- (void) dealloc {
	self.thumb = nil;
	self.textview = nil;
	self.titlelabel = nil;
	self.datelabel = nil;
	[super dealloc];
}

- (void) viewDidLoad
{
	[super viewDidLoad];

	self.navigationItem.title = NSLocalizedStringFromTable(@"title.transcript", @"TerpLocalize", nil);

	UIBarButtonItem *sendbutton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(buttonSend:)] autorelease];
	self.navigationItem.rightBarButtonItem = sendbutton;

	titlelabel.text = thumb.label;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		/* No room for this on the iphone layout */
		datelabel.hidden = YES;
	}
	else {
		RelDateFormatter *dateformatter = [[[RelDateFormatter alloc] init] autorelease];
		[dateformatter setDateStyle:NSDateFormatterMediumStyle];
		[dateformatter setTimeStyle:NSDateFormatterShortStyle];
		datelabel.text = [dateformatter stringFromDate:thumb.modtime];
	}

	NSString *str = [NSString stringWithContentsOfFile:thumb.pathname encoding:NSUTF8StringEncoding error:nil];
	if (str)
		textview.text = str;

	if (true) {
		UISwipeGestureRecognizer *recognizer;
		recognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)] autorelease];
		recognizer.direction = UISwipeGestureRecognizerDirectionRight;
		[textview addGestureRecognizer:recognizer];
	}
}

- (void) handleSwipeRight:(UIGestureRecognizer *)recognizer {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) buttonSend:(id)sender
{
	if ([UIActivityViewController class]) {
		// Available in iOS6+
		NSArray *ls = [NSArray arrayWithObject:textview.text];
		UIActivityViewController *actvc = [[[UIActivityViewController alloc] initWithActivityItems:ls applicationActivities:nil] autorelease];
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			[self presentViewController:actvc animated:YES completion:nil];
		}
		else {
			UIPopoverController *popover = [[[UIPopoverController alloc] initWithContentViewController:actvc] autorelease];
			[popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		}
		return;
	}
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
	return [[IosGlkViewController singleton] shouldAutorotateToInterfaceOrientation:orientation];
}


@end
