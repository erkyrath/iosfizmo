/* NotesViewController.h: Interpreter notes tab view controller
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import <UIKit/UIKit.h>

@interface NotesViewController : UIViewController <UITextViewDelegate> {
	BOOL textchanged;
}

@property (nonatomic, retain) IBOutlet UITextView *textview;

@property (nonatomic, retain) NSString *notespath;

- (IBAction) toggleKeyboard;
- (IBAction) handleTranscripts;
- (void) saveIfNeeded;

- (void) adjustToKeyboardBox;

@end
