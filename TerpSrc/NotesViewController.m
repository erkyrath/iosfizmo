/* NotesViewController.m: Interpreter notes tab view controller
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import "NotesViewController.h"
#import "IosGlkViewController.h"

#define NOTES_SAVE_DELAY (60)

@implementation NotesViewController

@synthesize textview;
@synthesize notespath;

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
	textview.delegate = self;
	
	/* We use an old-fashioned way of locating the Documents directory. (The NSManager method for this is iOS 4.0 and later.) */
	
	if (!notespath) {
		NSArray *dirlist = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		if (dirlist.count) {
			NSString *dir = [dirlist objectAtIndex:0];
			self.notespath = [dir stringByAppendingPathComponent:@"PlayerNotes.txt"];
		}
	}
	
	textchanged = NO;
	
	if (notespath) {
		NSString *str = [NSString stringWithContentsOfFile:notespath encoding:NSUTF8StringEncoding error:nil];
		if (str)
			textview.text = str;
	}
}

- (void) viewWillUnload
{
	NSLog(@"NotesVC: viewWillUnload");
	[self saveIfNeeded];
	textview.delegate = nil;
}

- (void) viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[self saveIfNeeded];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
	IosGlkViewController *glkviewc = [IosGlkViewController singleton];
	return [glkviewc shouldAutorotateToInterfaceOrientation:orientation];
}

- (IBAction) toggleKeyboard
{
	if ([textview isFirstResponder]) {
		[textview resignFirstResponder];
	}
	else {
		[textview becomeFirstResponder];
	}
}

- (void) saveIfNeeded
{
	if (!textchanged)
		return;
	NSLog(@"NotesVC: saving notes");
	textchanged = NO;
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(saveIfNeeded) object:nil];
	if (notespath && textview.text) {
		[textview.text writeToFile:notespath atomically:YES encoding:NSUTF8StringEncoding error:nil];
	}
}

/* UITextView delegate method */

- (void) textViewDidChange:(UITextView *)textView
{
	if (!textchanged) {
		textchanged = YES;
		[self performSelector:@selector(saveIfNeeded) withObject:nil afterDelay:NOTES_SAVE_DELAY];
	}
}

@end

