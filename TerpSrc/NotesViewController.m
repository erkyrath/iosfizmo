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

- (void) viewDidLoad
{
	[super viewDidLoad];

	_textview.delegate = self;

    BOOL isPhone = (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone);

//	UIEdgeInsets insets = UIEdgeInsetsMake(_buttontable.bounds.size.height, 0, 0, 0);
//    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 0, 0);
//	_textview.contentInset = insets;
//	_textview.scrollIndicatorInsets = insets;

	if ([_buttontable respondsToSelector:@selector(backgroundView)]) {
		/* This is only available in iOS 3.2 and up */
		_buttontable.backgroundView = [[UIView alloc] initWithFrame:_buttontable.backgroundView.frame];
//		if (isPhone) {
//			_buttontable.backgroundView.backgroundColor = [UIColor colorWithRed:1.0 green:0.98 blue:0.92 alpha:1];
//		}
//		else {
//			_buttontable.backgroundView.backgroundColor = [UIColor colorWithRed:0.85 green:0.8 blue:0.6 alpha:1];
//		}
	}

	/* Create the cells... */
	self.transcriptcell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Notes"];
//	_transcriptcell.backgroundColor = [UIColor colorWithRed:1.0 green:0.98 blue:0.92 alpha:1];
    _transcriptcell.backgroundColor = [UIColor colorNamed:@"CustomCellBackground"];
	_transcriptcell.textLabel.text = NSLocalizedStringFromTable(@"title.transcripts", @"TerpLocalize", nil);
//	_transcriptcell.textLabel.textColor = [UIColor colorWithRed:0.35 green:0.215 blue:0 alpha:1];
	if (isPhone)
		_transcriptcell.textLabel.font = [_transcriptcell.textLabel.font fontWithSize:17];
	_transcriptcell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    if (!isPhone)
        _textview.font = [_textview.font fontWithSize:16];

	/* Bang on font if Noteworthy is not available. I don't know why Marker Felt needs to be so enormous to fit the same grid as Noteworthy, though. */
	if ([_textview.font.familyName isEqualToString:@"Helvetica"]) {
		CGFloat fontsize;
		if (isPhone)
			fontsize = 21;
		else
			fontsize = 25;
		UIFont *font = [UIFont fontWithName:@"MarkerFelt-Thin" size:fontsize];
		if (font)
			_textview.font = font;
		else
			_textview.font = [UIFont systemFontOfSize:fontsize];
	}

    _textview.textColor = [UIColor blackColor];

	UIImage *stripeimg = nil;
	if (@available(iOS 5, *)) {
		if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
			stripeimg = [UIImage imageNamed:@"background-notes-s"];
		else
			stripeimg = [UIImage imageNamed:@"background-notes"];
		if (stripeimg)
			_textview.backgroundColor = [UIColor colorWithPatternImage:stripeimg];

		[_gradview setUpColorsPreset:1];
	}
	else {
		/* Transparent background colors won't load properly. We substitute opaque ones, which handily cover up the missing gradient view. */
		if (isPhone)
			stripeimg = [UIImage imageNamed:@"background-notesopaque-s"];
		else
			stripeimg = [UIImage imageNamed:@"background-notesopaque"];
		if (stripeimg)
			_textview.backgroundColor = [UIColor colorWithPatternImage:stripeimg];
	}

	/* We use an old-fashioned way of locating the Documents directory. (The NSManager method for this is iOS 4.0 and later.) */

	if (!_notespath) {
		NSArray *dirlist = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		if (dirlist.count) {
			NSString *dir = dirlist[0];
			self.notespath = [dir stringByAppendingPathComponent:@"PlayerNotes.txt"];
		}
	}

	textchanged = NO;

	if (_notespath) {
		NSString *str = [NSString stringWithContentsOfFile:_notespath encoding:NSUTF8StringEncoding error:nil];
		if (str)
			_textview.text = str;
	}

	/* Interface Builder currently doesn't allow us to set the voiceover labels for bar button items. We do it in code. */
	UIBarButtonItem *keyboardbutton = self.navigationItem.rightBarButtonItem;
	if (keyboardbutton && [keyboardbutton respondsToSelector:@selector(setAccessibilityLabel:)]) {
		[keyboardbutton setAccessibilityLabel:NSLocalizedStringFromTable(@"label.keyboard", @"TerpLocalize", nil)];
	}

	if ([IosGlkAppDelegate oldstyleui]) {
		/* Use the old-style drop-shadowed buttons in the navbar. */
		if (keyboardbutton)
			keyboardbutton.image = [UIImage imageNamed:@"baricon-edit-old"];
	}

	if (true) {
		FizmoGlkViewController *mainviewc = [FizmoGlkViewController singleton];
		UISwipeGestureRecognizer *recognizer;
		recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:mainviewc action:@selector(handleSwipeLeft:)];
		recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
		[_textview addGestureRecognizer:recognizer];
		recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:mainviewc action:@selector(handleSwipeRight:)];
		recognizer.direction = UISwipeGestureRecognizerDirectionRight;
		[_textview addGestureRecognizer:recognizer];
	}
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

- (IBAction) toggleKeyboard
{
	if (_textview.isFirstResponder) {
		[_textview resignFirstResponder];
	}
	else {
		[_textview becomeFirstResponder];
	}
    [self adjustToKeyboardBox];
}

- (void) adjustToKeyboardBox {
	CGRect keyboardbox = [IosGlkViewController singleton].keyboardbox;
	/* This rect is in window coordinates. */

	if (_textview) {
		CGFloat offset = 0;

		if (keyboardbox.size.width > 0 && keyboardbox.size.height > 0) {
			CGRect box = _textview.bounds;
			CGFloat bottom = box.origin.y + box.size.height;
			CGRect rect = [_textview convertRect:keyboardbox fromView:nil];
			if (rect.origin.y < bottom) {
				offset = rect.origin.y - bottom;
			}
		}
        _textbottomconstraint.constant = offset;
        [_textview layoutIfNeeded];
	}
}

- (IBAction) handleTranscripts
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Transcript" bundle:nil];
    UINavigationController *navc = [sb instantiateViewControllerWithIdentifier:@"transcriptnav"];
    [self.navigationController pushViewController:navc.viewControllers[0] animated:YES];
}

- (void) saveIfNeeded
{
	if (!textchanged)
		return;
	textchanged = NO;
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(saveIfNeeded) object:nil];
	if (_notespath && _textview.text) {
		[_textview.text writeToFile:_notespath atomically:YES encoding:NSUTF8StringEncoding error:nil];
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

/* UITableViewDataSource methods */

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexpath
{
	switch (indexpath.row) {
		case 0:
			return _transcriptcell;
		default:
            abort();
	}
}

/* UITableViewDelegate methods */

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexpath
{
	[_buttontable deselectRowAtIndexPath:indexpath animated:NO];
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

