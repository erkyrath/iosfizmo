/* FizmoGameOverView.h: Fizmo "Game Over" pop-up dialog
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import <UIKit/UIKit.h>
#import "GameOverView.h"

@interface FizmoGameOverView : GameOverView

- (IBAction) handleRestartButton:(id)sender;
- (IBAction) handleRestoreButton:(id)sender;
- (IBAction) handleQuitButton:(id)sender;

@end
