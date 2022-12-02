/* SettingsViewController.h: Interpreter settings tab view controller
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableview;

@property (nonatomic, strong) IBOutlet UITableViewCell *autocorrectcell;
@property (nonatomic, strong) IBOutlet UITableViewCell *keepopencell;
@property (nonatomic, strong) IBOutlet UITableViewCell *sharefilescell;
@property (nonatomic, strong) IBOutlet UITableViewCell *licensecell;

@property (nonatomic, strong) IBOutlet UISwitch *autocorrectswitch;
@property (nonatomic, strong) IBOutlet UISwitch *keepopenswitch;

- (IBAction) handleAutoCorrect:(id)sender;
- (IBAction) handleKeepOpen:(id)sender;
- (void) handleLicenses;
- (void) handleShareFiles;
- (void) handleShareFilesHighlightUsage:(int)usage name:(NSString *)filename;

@end
