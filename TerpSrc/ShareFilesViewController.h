/* ShareFilesViewController.h: Files list overview display view controller
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import <UIKit/UIKit.h>

@class GlkFileRefPrompt;
@class GlkFileThumb;

@interface ShareFilesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIDocumentInteractionControllerDelegate> {
	UITableView *tableView;
	UIBarButtonItem *sendbutton;
	int highlightusage;
	NSString *highlightname;
	UIDocumentInteractionController *sharedocic;
	NSString *sharetemppath;
	
	NSMutableArray *filelists; // array of (nonempty) arrays of GlkFileThumb
	NSDateFormatter *dateformatter;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIBarButtonItem *sendbutton;
@property (nonatomic) int highlightusage;
@property (nonatomic, strong) NSString *highlightname;
@property (nonatomic, strong) UIDocumentInteractionController *sharedocic;
@property (nonatomic, strong) NSString *sharetemppath;
@property (nonatomic, strong) NSMutableArray *filelists;
@property (nonatomic, strong) NSDateFormatter *dateformatter;

- (void) addBlankThumb;

@end
