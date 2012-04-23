/* DisplayTextViewController.h: Transcript display view controller
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@class GlkFileThumb;

@interface DisplayTextViewController : UIViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, retain) IBOutlet UITextView *textview;
@property (nonatomic, retain) IBOutlet UILabel *titlelabel;
@property (nonatomic, retain) IBOutlet UILabel *datelabel;
@property (nonatomic, retain) GlkFileThumb *thumb;
@property (nonatomic, retain) UIActionSheet *exportsheet;

- (id) initWithNibName:(NSString *)nibName thumb:(GlkFileThumb *)thumb bundle:(NSBundle *)nibBundle;

@end
