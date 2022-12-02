/* DisplayTextViewController.h: Transcript display view controller
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import <UIKit/UIKit.h>

@class GlkFileThumb;

@interface DisplayTextViewController : UIViewController <UIActionSheetDelegate>

@property (nonatomic, strong) IBOutlet UITextView *textview;
@property (nonatomic, strong) IBOutlet UILabel *titlelabel;
@property (nonatomic, strong) IBOutlet UILabel *datelabel;
@property (nonatomic, strong) GlkFileThumb *thumb;

- (instancetype) initWithNibName:(NSString *)nibName thumb:(GlkFileThumb *)thumb bundle:(NSBundle *)nibBundle;

@end
