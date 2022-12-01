/* NotesViewController.h: Interpreter notes tab view controller
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import <UIKit/UIKit.h>

@class GradientView;
@class MButton;
@class UnderlinedTextView;

@interface NotesViewController : UIViewController <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet GradientView *gradview;
@property (nonatomic, strong) IBOutlet UnderlinedTextView *textview;
@property (nonatomic, strong) IBOutlet UITableView *buttontable;
@property (nonatomic, strong) IBOutlet UITableViewCell *transcriptcell;
@property (nonatomic, strong) NSString *notespath;

- (IBAction) toggleKeyboard;
- (IBAction) handleTranscripts;
- (void) saveIfNeeded;

@end
