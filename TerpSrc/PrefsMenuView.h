/* PrefsMenuView.h: A popmenu subclass that can display the preferences menu
 for IosGlk, the iOS implementation of the Glk API.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import <UIKit/UIKit.h>
#import "PopMenuView.h"

@interface PrefsMenuView : PopMenuView

@property (nonatomic, retain) IBOutlet UIView *container;
@property (nonatomic, retain) IBOutlet UIButton *colbut_full;
@property (nonatomic, retain) IBOutlet UIButton *colbut_34;
@property (nonatomic, retain) IBOutlet UIButton *colbut_12;
@property (nonatomic, retain) IBOutlet UIButton *sizebut_small;
@property (nonatomic, retain) IBOutlet UIButton *sizebut_big;
@property (nonatomic, retain) IBOutlet UIButton *fontbutton;
@property (nonatomic, retain) IBOutlet UIButton *colorbutton;

- (void) updateButtons;
- (IBAction) handleColumnWidth:(id)sender;

@end


@interface PrefsContainerView : UIView

@end
