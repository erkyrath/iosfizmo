/* NotesViewController.m: Interpreter notes tab view controller
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import "NotesViewController.h"
#import "FizmoGlkViewController.h"
#import "IosGlkViewController.h"
#import "TranscriptViewController.h"
#import "GradientView.h"
#import "MButton.h"
#import "IosGlkAppDelegate.h"

#define NOTES_SAVE_DELAY (60)

@implementation NotesViewController

@synthesize textview;
@synthesize gradview;
@synthesize buttontable;
@synthesize transcriptcell;
@synthesize notespath;

- (void) dealloc {
	self.textview = nil;
	self.gradview = nil;
	self.buttontable = nil;
	self.transcriptcell = nil;
	[super dealloc];
}

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	textview.delegate = self;
	
	UIEdgeInsets insets = UIEdgeInsetsMake(buttontable.bounds.size.height, 0, 0, 0);
	textview.contentInset = insets;
	textview.scrollIndicatorInsets = insets;
	
	if ([buttontable respondsToSelector:@selector(backgroundView)]) {
		/* This is only available in iOS 3.2 and up */
		buttontable.backgroundView = [[[UIView alloc] initWithFrame:buttontable.backgroundView.frame] autorelease];
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			buttontable.backgroundView.backgroundColor = [UIColor colorWithRed:1.0 green:0.98 blue:0.92 alpha:1];
		}
		else {
			buttontable.backgroundView.backgroundColor = [UIColor colorWithRed:0.85 green:0.8 blue:0.6 alpha:1];
		}
	}
	
	/* Create the cells... */
	self.transcriptcell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Notes"] autorelease];
	transcriptcell.backgroundColor = [UIColor colorWithRed:1.0 green:0.98 blue:0.92 alpha:1];
	transcriptcell.textLabel.text = NSLocalizedStringFromTable(@"title.transcripts", @"TerpLocalize", nil);
	transcriptcell.textLabel.textColor = [UIColor colorWithRed:0.35 green:0.215 blue:0 alpha:1];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
		transcriptcell.textLabel.font = [transcriptcell.textLabel.font fontWithSize:17];
	transcriptcell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	/* Bang on font if Noteworthy is not available. I don't know why Marker Felt needs to be so enormous to fit the same grid as Noteworthy, though. */
	if ([textview.font.familyName isEqualToString:@"Helvetica"]) {
		CGFloat fontsize;
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
			fontsize = 21;
		else
			fontsize = 25;
		UIFont *font = [UIFont fontWithName:@"MarkerFelt-Thin" size:fontsize];
		if (font)
			textview.font = font;
		else
			textview.font = [UIFont systemFontOfSize:fontsize];
	}
	
	NSString *reqSysVer = @"5.0";
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	BOOL hasios5 = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
	
	UIImage *stripeimg = nil;
	if (hasios5) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
			stripeimg = [UIImage imageNamed:@"background-notes-s"];
		else
			stripeimg = [UIImage imageNamed:@"background-notes"];
		if (stripeimg)
			textview.backgroundColor = [UIColor colorWithPatternImage:stripeimg];
		
		[gradview setUpColorsPreset:1];
	}
	else {
		/* Transparent background colors won't load properly. We substitute opaque ones, which handily cover up the missing gradient view. */
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
			stripeimg = [UIImage imageNamed:@"background-notesopaque-s"];
		else
			stripeimg = [UIImage imageNamed:@"background-notesopaque"];
		if (stripeimg)
			textview.backgroundColor = [UIColor colorWithPatternImage:stripeimg];
	}
	
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

	/* Interface Builder currently doesn't allow us to set the voiceover labels for bar button items. We do it in code. */
	UIBarButtonItem *keyboardbutton = self.navigationItem.rightBarButtonItem;
	if (keyboardbutton && [keyboardbutton respondsToSelector:@selector(setAccessibilityLabel:)]) {
		[keyboardbutton setAccessibilityLabel:NSLocalizedStringFromTable(@"label.keyboard", @"TerpLocalize", nil)];
	}

	if ([IosGlkAppDelegate oldstyleui]) {
		/* Use the old-style drop-shadowed buttons in the navbar. */
		if (keyboardbutton)
			[keyboardbutton setImage:[UIImage imageNamed:@"baricon-edit-old"]];
	}
	
	if (true) {
		FizmoGlkViewController *mainviewc = [FizmoGlkViewController singleton];
		UISwipeGestureRecognizer *recognizer;
		recognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:mainviewc action:@selector(handleSwipeLeft:)] autorelease];
		recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
		[textview addGestureRecognizer:recognizer];
		recognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:mainviewc action:@selector(handleSwipeRight:)] autorelease];
		recognizer.direction = UISwipeGestureRecognizerDirectionRight;
		[textview addGestureRecognizer:recognizer];
	}
}

- (void) viewWillUnload
{
	[super viewWillUnload];
	
	[self saveIfNeeded];
	textview.delegate = nil;
}

/* Called both when you leave the Notes tab, and when the notes view is covered by a pushed transcript view.
 */
- (void) viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[self saveIfNeeded];
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self adjustToKeyboardBox];
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

- (void) adjustToKeyboardBox {
	CGRect keyboardbox = [IosGlkViewController singleton].keyboardbox;
	/* This rect is in window coordinates. */
	
	if (textview) {
		CGFloat offset = 0;
		
		if (keyboardbox.size.width > 0 && keyboardbox.size.height > 0) {
			CGRect box = textview.bounds;
			CGFloat bottom = box.origin.y + box.size.height;
			CGRect rect = [textview convertRect:keyboardbox fromView:nil];
			if (rect.origin.y < bottom) {
				offset = bottom - rect.origin.y;
			}
		}
		
		UIEdgeInsets insets = UIEdgeInsetsMake(buttontable.bounds.size.height, 0, offset, 0);
		textview.contentInset = insets;
		textview.scrollIndicatorInsets = insets;
	}
}

- (IBAction) handleTranscripts
{
	TranscriptViewController *transviewc = [[[TranscriptViewController alloc] initWithNibName:@"TranscriptVC" bundle:nil] autorelease];
	[self.navigationController pushViewController:transviewc animated:YES];
}

- (void) saveIfNeeded
{
	if (!textchanged)
		return;
	textchanged = NO;
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(saveIfNeeded) object:nil];
	if (notespath && textview.text) {
		[textview.text writeToFile:notespath atomically:YES encoding:NSUTF8StringEncoding error:nil];
	}
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGRect rect = buttontable.frame;
	rect.origin.y = -textview.contentOffset.y - rect.size.height;
	if (rect.origin.y > 0)
		rect.origin.y = 0;
	buttontable.frame = rect;
}

/* UITextView delegate method */

- (void) textViewDidChange:(UITextView *)textView
{
	if (!textchanged) {
		textchanged = YES;
		[self performSelector:@selector(saveIfNeeded) withObject:nil afterDelay:NOTES_SAVE_DELAY];
	}
}

/* UITableViewDataSource methods */

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexpath
{
	switch (indexpath.row) {
		case 0:
			return transcriptcell;
		default:
			return nil;
	}
}

/* UITableViewDelegate methods */

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexpath
{
	[buttontable deselectRowAtIndexPath:indexpath animated:NO];
	if (indexpath.row == 0)
		[self handleTranscripts];
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	return nil;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return nil;
}


@end

