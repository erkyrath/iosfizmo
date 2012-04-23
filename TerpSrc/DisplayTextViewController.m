/* DisplayTextViewController.m: Transcript display view controller
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import "DisplayTextViewController.h"
#import "RelDateFormatter.h"
#import "GlkFileTypes.h"

@implementation DisplayTextViewController

@synthesize textview;
@synthesize titlelabel;
@synthesize datelabel;
@synthesize thumb;
@synthesize exportsheet;

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
	self.exportsheet = nil;
	[super dealloc];
}

- (void) viewDidLoad
{
	[super viewDidLoad];

	self.navigationItem.title = NSLocalizedStringFromTable(@"title.transcript", @"TerpLocalize", nil);

	UIBarButtonItem *sendbutton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(buttonSend:)] autorelease];
	sendbutton.enabled = [MFMailComposeViewController canSendMail];
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

	if ([textview respondsToSelector:@selector(addGestureRecognizer:)]) {
		/* gestures are available in iOS 3.2 and up */
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
	self.exportsheet = [[[UIActionSheet alloc]
						 initWithTitle:nil
						 delegate:self
						 cancelButtonTitle:NSLocalizedStringFromTable(@"button.cancel", @"TerpLocalize", nil)
						 destructiveButtonTitle:nil
						 otherButtonTitles:
						 NSLocalizedStringFromTable(@"label.copy-all", @"TerpLocalize", nil),
						 NSLocalizedStringFromTable(@"label.email", @"TerpLocalize", nil),
						 nil] autorelease];
	[exportsheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}

- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	self.exportsheet = nil;
	
	switch (buttonIndex) {
		case 0:
			[UIPasteboard generalPasteboard].string = textview.text;
			break;
			
		case 1: {
			MFMailComposeViewController *compose = [[MFMailComposeViewController alloc] init];
			compose.mailComposeDelegate = self;
			
			NSString *subjstr = [NSString stringWithFormat:@"%@: %@", NSLocalizedStringFromTable(@"title.transcript", @"TerpLocalize", nil), thumb.label];
			[compose setSubject:subjstr];
			[compose setMessageBody:textview.text isHTML:NO];
			
			[self presentModalViewController:compose animated:YES];
			[compose release]; // Can safely release the controller now.
			}
			break;
	}
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
