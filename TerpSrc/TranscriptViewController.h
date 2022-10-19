/* TranscriptViewController.h: Transcript overview display view controller
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import <UIKit/UIKit.h>

@class GlkFileRefPrompt;
@class GlkFileThumb;

@interface TranscriptViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
	UITableView *tableView;
	
	NSMutableArray *filelist; // array of GlkFileThumb
	NSDateFormatter *dateformatter;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *filelist;
@property (nonatomic, strong) NSDateFormatter *dateformatter;

- (void) addBlankThumb;

@end
