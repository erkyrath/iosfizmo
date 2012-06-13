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

@property (nonatomic, retain) IBOutlet PrefsContainerView *container;
@property (nonatomic, retain) IBOutlet PrefsContainerView *fontscontainer;
@property (nonatomic, retain) IBOutlet PrefsContainerView *colorscontainer;
@property (nonatomic, retain) IBOutlet UIButton *colorsbutton;
@property (nonatomic, retain) IBOutlet UIButton *fontsbutton;
@property (nonatomic, retain) IBOutlet UISlider *brightslider;
@property (nonatomic, retain) IBOutlet MButton *colbut_full;
@property (nonatomic, retain) IBOutlet MButton *colbut_34;
@property (nonatomic, retain) IBOutlet MButton *colbut_12;
@property (nonatomic, retain) IBOutlet MButton *sizebut_small;
@property (nonatomic, retain) IBOutlet MButton *sizebut_big;
@property (nonatomic, retain) IBOutlet MButton *leadbut_small;
@property (nonatomic, retain) IBOutlet MButton *leadbut_big;
@property (nonatomic, retain) IBOutlet UIButton *fontbutton;
@property (nonatomic, retain) IBOutlet UIButton *colorbutton;
@property (nonatomic, retain) IBOutlet MButton *fontbut_sample1;
@property (nonatomic, retain) IBOutlet MButton *fontbut_sample2;
@property (nonatomic, retain) IBOutlet MButton *colorbut_bright;
@property (nonatomic, retain) IBOutlet MButton *colorbut_quiet;
@property (nonatomic, retain) IBOutlet MButton *colorbut_dark;

@property (nonatomic) BOOL supportsbrightness;
@property (nonatomic, retain) NSArray *fontnames;
@property (nonatomic, retain) NSArray *fontbuttons;

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
