/* PrefsMenuView.h: A popmenu subclass that can display the preferences menu
 for IosGlk, the iOS implementation of the Glk API.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import <UIKit/UIKit.h>
#import "PopMenuView.h"

@class PrefsContainerView;

@interface PrefsMenuView : PopMenuView

@property (nonatomic, retain) IBOutlet PrefsContainerView *container;
@property (nonatomic, retain) IBOutlet PrefsContainerView *fontscontainer;
@property (nonatomic, retain) IBOutlet PrefsContainerView *colorscontainer;
@property (nonatomic, retain) IBOutlet UIButton *colorsbutton;
@property (nonatomic, retain) IBOutlet UIButton *fontsbutton;
@property (nonatomic, retain) IBOutlet UIButton *colbut_full;
@property (nonatomic, retain) IBOutlet UIButton *colbut_34;
@property (nonatomic, retain) IBOutlet UIButton *colbut_12;
@property (nonatomic, retain) IBOutlet UIButton *sizebut_small;
@property (nonatomic, retain) IBOutlet UIButton *sizebut_big;
@property (nonatomic, retain) IBOutlet UIButton *fontbutton;
@property (nonatomic, retain) IBOutlet UIButton *colorbutton;
@property (nonatomic, retain) IBOutlet UIButton *fontbut_sample1;
@property (nonatomic, retain) IBOutlet UIButton *fontbut_sample2;
@property (nonatomic, retain) IBOutlet UIButton *colorbut_bright;
@property (nonatomic, retain) IBOutlet UIButton *colorbut_quiet;
@property (nonatomic, retain) IBOutlet UIButton *colorbut_dark;

- (void) updateButtons;
- (IBAction) handleColumnWidth:(id)sender;
- (IBAction) handleFontSize:(id)sender;
- (IBAction) handleFonts:(id)sender;
- (IBAction) handleFont:(id)sender;
- (IBAction) handleColors:(id)sender;
- (IBAction) handleColor:(id)sender;

@end


@interface PrefsContainerView : UIView

@end
