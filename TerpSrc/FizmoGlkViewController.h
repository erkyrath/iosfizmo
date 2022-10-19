/* FizmoGlkViewController.h: Fizmo-specific subclass of the IosGlk view controller
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import <UIKit/UIKit.h>
#import "IosGlkViewController.h"

@class NotesViewController;
@class SettingsViewController;
@class FizmoGlkDelegate;
@class GlkFileRefPrompt;

@interface FizmoGlkViewController : IosGlkViewController <UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet NotesViewController *notesvc;
@property (nonatomic, strong) IBOutlet SettingsViewController *settingsvc;
@property (nonatomic, strong) GlkFileRefPrompt *restorefileprompt;

+ (FizmoGlkViewController *) singleton;

@property (NS_NONATOMIC_IOSONLY, readonly, strong) FizmoGlkDelegate *fizmoDelegate;
- (IBAction) showPreferences;
- (void) handleSwipeLeft:(UIGestureRecognizer *)recognizer;
- (void) handleSwipeRight:(UIGestureRecognizer *)recognizer;

@end

#if 0 /* tab-slide not yet working */

@interface TabSlideTransitioning : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic) BOOL forwards;

@end

#endif /* 0 */

