/* PrefsMenuView.h: A popmenu subclass that can display the preferences menu
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import <UIKit/UIKit.h>
#import "PopMenuView.h"

@class PrefsContainerView;
@class MButton;

@interface PrefsMenuView : PopMenuView

@property (nonatomic, strong) IBOutlet PrefsContainerView *container;
@property (nonatomic, strong) IBOutlet PrefsContainerView *fontscontainer;
@property (nonatomic, strong) IBOutlet PrefsContainerView *colorscontainer;
@property (nonatomic, strong) IBOutlet UIButton *colorsbutton;
@property (nonatomic, strong) IBOutlet UIButton *fontsbutton;
@property (nonatomic, strong) IBOutlet UISlider *brightslider;
@property (nonatomic, strong) IBOutlet MButton *colbut_full;
@property (nonatomic, strong) IBOutlet MButton *colbut_34;
@property (nonatomic, strong) IBOutlet MButton *colbut_12;
@property (nonatomic, strong) IBOutlet MButton *sizebut_small;
@property (nonatomic, strong) IBOutlet MButton *sizebut_big;
@property (nonatomic, strong) IBOutlet MButton *leadbut_small;
@property (nonatomic, strong) IBOutlet MButton *leadbut_big;
@property (nonatomic, strong) IBOutlet UIButton *fontbutton;
@property (nonatomic, strong) IBOutlet UIButton *colorbutton;
@property (nonatomic, strong) IBOutlet MButton *fontbut_sample1;
@property (nonatomic, strong) IBOutlet MButton *fontbut_sample2;
@property (nonatomic, strong) IBOutlet MButton *colorbut_bright;
@property (nonatomic, strong) IBOutlet MButton *colorbut_quiet;
@property (nonatomic, strong) IBOutlet MButton *colorbut_dark;

@property (nonatomic) BOOL supportsbrightness;
@property (nonatomic, strong) NSArray *fontnames;
@property (nonatomic, strong) NSArray *fontbuttons;

- (void) updateButtons;
- (IBAction) handleColumnWidth:(id)sender;
- (IBAction) handleFontSize:(id)sender;
- (IBAction) handleFontLeading:(id)sender;
- (IBAction) handleFonts:(id)sender;
- (IBAction) handleFont:(id)sender;
- (IBAction) handleColors:(id)sender;
- (IBAction) handleColor:(id)sender;
- (IBAction) handleBrightChanged:(id)sender;

@end


@interface PrefsContainerView : UIView

@end
