/* FizmoGlkViewController.h: Fizmo-specific subclass of the IosGlk view controller
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import <UIKit/UIKit.h>
#import "IosGlkViewController.h"

@class NotesViewController;
@class FizmoGlkDelegate;
@class GlkFileRefPrompt;

@interface FizmoGlkViewController : IosGlkViewController <UIGestureRecognizerDelegate>

@property (nonatomic, retain) IBOutlet NotesViewController *notesvc;
@property (nonatomic, retain) GlkFileRefPrompt *restorefileprompt;

+ (FizmoGlkViewController *) singleton;

- (FizmoGlkDelegate *) fizmoDelegate;
- (IBAction) showPreferences;

@end
