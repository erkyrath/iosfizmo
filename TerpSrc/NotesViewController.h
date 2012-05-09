/* NotesViewController.h: Interpreter notes tab view controller
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import <UIKit/UIKit.h>

@class GradientView;
@class MButton;

@interface NotesViewController : UIViewController <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate> {
	BOOL textchanged;
}

@property (nonatomic, retain) IBOutlet GradientView *gradview;
@property (nonatomic, retain) IBOutlet UITextView *textview;
@property (nonatomic, retain) IBOutlet UITableView *buttontable;
@property (nonatomic, retain) IBOutlet UITableViewCell *transcriptcell;

@property (nonatomic, retain) NSString *notespath;

- (IBAction) toggleKeyboard;
- (IBAction) handleTranscripts;
- (void) saveIfNeeded;

- (void) adjustToKeyboardBox;

@end
