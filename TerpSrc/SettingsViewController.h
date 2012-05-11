/* SettingsViewController.h: Interpreter settings tab view controller
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tableview;

@property (nonatomic, retain) IBOutlet UITableViewCell *autocorrectcell;
@property (nonatomic, retain) IBOutlet UITableViewCell *morepromptcell;
@property (nonatomic, retain) IBOutlet UITableViewCell *licensecell;

@property (nonatomic, retain) IBOutlet UISwitch *autocorrectswitch;
@property (nonatomic, retain) IBOutlet UISwitch *morepromptswitch;

- (IBAction) handleAutoCorrect:(id)sender;
- (IBAction) handleMorePrompt:(id)sender;
- (void) handleLicenses;

@end
