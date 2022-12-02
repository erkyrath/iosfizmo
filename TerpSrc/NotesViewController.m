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
#import "UnderlinedTextView.h"

#define NOTES_SAVE_DELAY (60)

@interface NotesViewController ()
{
    BOOL textchanged;
    CGRect keyboardbox;
}

@end

@implementation NotesViewController

- (void) viewDidLoad
{
	[super viewDidLoad];

	_textview.delegate = self;

    BOOL isPhone = (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone);

	/* Create the cells... */
	self.transcriptcell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Notes"];
    _transcriptcell.backgroundColor = [UIColor colorNamed:@"CustomCellBackground"];
	_transcriptcell.textLabel.text = NSLocalizedStringFromTable(@"title.transcripts", @"TerpLocalize", nil);
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

    _textview.textColor = [UIColor colorNamed:@"CustomText"];

	[_gradview setUpColorsPreset:1];

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

- (void) viewWillAppear:(BOOL)paramAnimated{
    [super viewWillAppear:paramAnimated];

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillBeShown:)
     name:UIKeyboardWillShowNotification object:nil];

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillBeHidden:)
     name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillBeShown:(NSNotification *)paramNotification {

    NSValue *keyboardRectAsObject =
    [[paramNotification userInfo]
     objectForKey:UIKeyboardFrameEndUserInfoKey];

    keyboardbox = CGRectZero;
    [keyboardRectAsObject getValue:&keyboardbox];

    if (_textview) {
        _textview.contentInset = UIEdgeInsetsMake(0, 0,
                                                  keyboardbox.size.height, 0);
        [_textview layoutIfNeeded];
        [_textview setNeedsDisplay];
    }
}

- (void) keyboardWillBeHidden:(NSNotification *)paramNotification {
    if (_textview) {
        if (_textview.animating)
            return;

        // Hack to hide the fact that the UnderlinedTextView lines get
        // out of sync with the text during the contentInset change
        // animation. We stop drawing the lines in drawRect during the
        // animation and instead add a temporary CAShapeLayer with identical
        // lines, which for some reason makes it look right.

        _textview.animating = YES;
        CAShapeLayer *linesLayer = [_textview createAnimationLayer];
        [_textview.layer addSublayer:linesLayer];

        UnderlinedTextView __weak *weakview = _textview;
        [UIView animateWithDuration:0.2 animations:^{
            weakview.contentInset = UIEdgeInsetsZero;
        } completion:^(BOOL finished) {
            [linesLayer removeFromSuperlayer];
            weakview.animating = NO;
            [weakview setNeedsDisplay];
        }];
    }
}

- (IBAction) toggleKeyboard
{
	if (_textview.isFirstResponder) {
		[_textview resignFirstResponder];
	}
	else {
		[_textview becomeFirstResponder];
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
    [_textview setNeedsDisplay];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
        [_gradview setUpColorsPreset:1];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_textview setNeedsDisplay];
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

