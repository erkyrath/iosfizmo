/* FizmoGlkViewController.m: Fizmo-specific subclass of the IosGlk view controller
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import "FizmoGlkViewController.h"
#import "FizmoGlkDelegate.h"
#import "GlkLibrary.h"
#import "GlkAppWrapper.h"
#import "GlkFileTypes.h"
#import "FizmoGameOverView.h"
#import "IosGlkAppDelegate.h"
#import "GlkFrameView.h"
#import "GlkWinBufferView.h"
#import "NotesViewController.h"
#import "SettingsViewController.h"
#import "PrefsMenuView.h"

// This typedef works around header file annoyance. We're not going to refer to it.
typedef struct z_file_struct z_file;
#include "ios-autosave.h"
#include "ios-restart.h"

@implementation FizmoGlkViewController

@synthesize notesvc;
@synthesize settingsvc;
@synthesize restorefileprompt;

+ (FizmoGlkViewController *) singleton {
	return (FizmoGlkViewController *)([IosGlkAppDelegate singleton].glkviewc);
}

- (FizmoGlkDelegate *) fizmoDelegate {
	return (FizmoGlkDelegate *)self.glkdelegate;
}

- (void) didFinishLaunching {
	[super didFinishLaunching];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	/* Set some reasonable defaults, if none have ever been set. */
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone) {
		/* On the iPad, use a 3/4 column and bump the leading a little. */
		if (![defaults objectForKey:@"FrameMaxWidth"])
			[defaults setInteger:1 forKey:@"FrameMaxWidth"];
		if (![defaults objectForKey:@"FontLeading"])
			[defaults setInteger:1 forKey:@"FontLeading"];
	}
	else {
		/* On the iPhone, leave everything as-is. */
	}
	
	int maxwidth = [defaults integerForKey:@"FrameMaxWidth"];
	self.fizmoDelegate.maxwidth = maxwidth;
	
	/* Font-scale values are arbitrarily between 1 and 5. We default to 3. */
	int fontscale = [defaults integerForKey:@"FontScale"];
	if (fontscale == 0)
		fontscale = 3;
	self.fizmoDelegate.fontscale = fontscale;
	
	/* Leading is between 0 and 5. */
	int leading = [defaults integerForKey:@"FontLeading"];
	self.fizmoDelegate.leading = leading;
	
	/* Color-scheme values are 0 to 2. */
	int colorscheme = [defaults integerForKey:@"ColorScheme"];
	self.fizmoDelegate.colorscheme = colorscheme;
	
	NSString *fontfamily = [defaults stringForKey:@"FontFamily"];
	if (!fontfamily)
		fontfamily = @"Georgia";
	self.fizmoDelegate.fontfamily = fontfamily;
	
	self.navigationController.navigationBar.barStyle = (self.fizmoDelegate.hasDarkTheme ? UIBarStyleBlack : UIBarStyleDefault);
	
	// Yes, this is in two places.
	self.frameview.backgroundColor = [self.fizmoDelegate genBackgroundColor];
}

- (void) becameInactive {
	[notesvc saveIfNeeded];
}

- (void) enteredBackground {
	[super enteredBackground];
	
	/* If the interpreter hit a "fatal error" state, and we're just waiting around to tell the user about it, we want the Home button to shut down the app. That is, the user can kill the app by backgrounding it. */
	GlkLibrary *library = [GlkLibrary singleton];
	if (library && library.vmexited && !iosglk_can_restart_cleanly()) {
		iosglk_shut_down_process();
	}
}

- (void) viewDidLoad {
	[super viewDidLoad];
	
	self.frameview.backgroundColor = [self.fizmoDelegate genBackgroundColor];
	
	if ([frameview respondsToSelector:@selector(addGestureRecognizer:)]) {
		/* gestures are available in iOS 3.2 and up */
		UISwipeGestureRecognizer *recognizer;
		recognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)] autorelease];
		recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
		recognizer.delegate = self;
		[frameview addGestureRecognizer:recognizer];
		recognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)] autorelease];
		recognizer.direction = UISwipeGestureRecognizerDirectionRight;
		recognizer.delegate = self;
		[frameview addGestureRecognizer:recognizer];
	}
	
	/* Interface Builder currently doesn't allow us to set the voiceover labels for bar button items. We do it in code. */
	UIBarButtonItem *stylebutton = self.navigationItem.leftBarButtonItem;
	if (stylebutton && [stylebutton respondsToSelector:@selector(setAccessibilityLabel:)]) {
		[stylebutton setAccessibilityLabel:NSLocalizedStringFromTable(@"label.text-styles", @"TerpLocalize", nil)];
	}
	UIBarButtonItem *keyboardbutton = self.navigationItem.rightBarButtonItem;
	if (keyboardbutton && [keyboardbutton respondsToSelector:@selector(setAccessibilityLabel:)]) {
		[keyboardbutton setAccessibilityLabel:NSLocalizedStringFromTable(@"label.compose-command", @"TerpLocalize", nil)];
	}
}

- (id) filterEvent:(id)data {
	if (self.vmexited && data && [data isKindOfClass:[GlkFileRefPrompt class]] && data == restorefileprompt) {
		/* Drop the field reference to the prompt. */
		GlkFileRefPrompt *prompt = restorefileprompt;
		[[prompt retain] autorelease];
		self.restorefileprompt = nil;
		
		if (!prompt.filename) {
			/* Cancelled. Forget it. */
			return nil;
		}
		
		/* Queue up the autorestore file, and restart the interpreter. */
		iosglk_queue_autosave(prompt.pathname);
		[[GlkAppWrapper singleton] acceptEventRestart];
		return nil;
	}
	
	return data;
}

- (void) postGameOver {
	CGRect rect = frameview.bounds;
	FizmoGameOverView *menuview = [[[FizmoGameOverView alloc] initWithFrame:frameview.bounds centerInFrame:rect] autorelease];
	[frameview postPopMenu:menuview];	
}

/* UITabBarController delegate method */
- (void) tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewc {
	if (![viewc isKindOfClass:[UINavigationController class]])
		return;
	UINavigationController *navc = (UINavigationController *)viewc;
	NSArray *viewcstack = navc.viewControllers;
	if (!viewcstack || !viewcstack.count)
		return;
	UIViewController *rootviewc = [viewcstack objectAtIndex:0];
	//NSLog(@"### tabBarController did select %@ (%@)", navc, rootviewc);
	
	if (rootviewc != notesvc) {
		/* If the notesvc was drilled into the transcripts view or subviews, pop out of there. */
		[notesvc.navigationController popToRootViewControllerAnimated:NO];
	}
	if (rootviewc != settingsvc) {
		/* If the settingsvc was drilled into the transcripts view or subviews, pop out of there. */
		[settingsvc.navigationController popToRootViewControllerAnimated:NO];
	}
}

/* UIGestureRecognizer delegate method */
- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	/* Turn off tab-swiping if an input menu is open. */
	if (!frameview)
		return NO;
	if (frameview.menuview)
		return NO;
	/* Reject the swipe if it's on a window's text-selection rectangle. */
	if (self.textselecttag) {
		GlkWindowView *winv = [frameview windowViewForTag:textselecttag];
		if (winv) {
			CGRect rect = winv.textSelectArea;
			if (rect.size.width > 0 && rect.size.height > 0) {
				CGPoint loc = [touch locationInView:winv];
				if (loc.y >= rect.origin.y - 32 && loc.y < rect.origin.y+rect.size.height + 32
					&& loc.x >= rect.origin.x && loc.x < rect.origin.x+rect.size.width) {
					return NO;
				}
			}
		}
	}
	return YES;
}

- (IBAction) toggleKeyboard {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		/* Can't have the prefs menu up at the same time as the keyboard -- the iPhone screen is too small. */
		if (frameview.menuview && [frameview.menuview isKindOfClass:[PrefsMenuView class]]) {
			[frameview removePopMenuAnimated:YES];
		}
	}
	[super toggleKeyboard];
}

- (void) keyboardWillBeShown:(NSNotification*)notification {
	[super keyboardWillBeShown:notification];
	//NSLog(@"Keyboard will be shown (fizmo)");

	if (notesvc) {
		[notesvc adjustToKeyboardBox];
	}
}

- (void) keyboardWillBeHidden:(NSNotification*)notification {
	[super keyboardWillBeHidden:notification];
	//NSLog(@"Keyboard will be hidden (fizmo)");

	if (notesvc) {
		[notesvc adjustToKeyboardBox];
	}
}

- (IBAction) showPreferences {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		/* Can't have the prefs menu up at the same time as the keyboard */
		[self hideKeyboard];
	}
	
	if (frameview.menuview && [frameview.menuview isKindOfClass:[PrefsMenuView class]]) {
		[frameview removePopMenuAnimated:YES];
		return;
	}
	
	CGRect rect = CGRectMake(4, 0, 40, 4);
	PrefsMenuView *menuview = [[[PrefsMenuView alloc] initWithFrame:frameview.bounds buttonFrame:rect belowButton:YES] autorelease];
	[frameview postPopMenu:menuview];
}

- (void) handleSwipeLeft:(UIGestureRecognizer *)recognizer {
	if (self.tabBarController) {
		int count = self.tabBarController.viewControllers.count;
		int val = (self.tabBarController.selectedIndex + 1) % count;
		self.tabBarController.selectedIndex = val;
	}
}

- (void) handleSwipeRight:(UIGestureRecognizer *)recognizer {
	if (self.tabBarController) {
		int count = self.tabBarController.viewControllers.count;
		int val = (self.tabBarController.selectedIndex + count - 1) % count;
		self.tabBarController.selectedIndex = val;
	}
}

@end
